class GamesController < ApplicationController
  # GET /games
  # GET /games.json
  def index
    if params[:user_id].blank?
      if params[:show_completed] == "1"
        @games = Game.all
      else
        @games = Game.where(:winning_player_id => nil)
      end
    else
      if params[:show_completed] == 1
        @games = User.find(params[:user_id]).games
      else
        @games = User.find(params[:user_id]).games.where(:winning_player_id => nil)
      end
    end

    @users = User.order("nickname")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @games }
    end
  end

  # GET /games/1
  # GET /games/1.json
  def show
    # Right now anyone can watch anyone's game, which I think is fine -- so long as they can't modify anything.
    # Riot Games: 2 years to add spectator mode
    # Quill18: About 4 hours into the project.

    @game = Game.find(params[:id], :include => [{:map => :tiles}])
    @player = @game.player_from_user(current_user)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @game }
    end
  end

  # GET /games/new
  # GET /games/new.json
  def new
    @game = Game.new

    @game.map_id = params[:map_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @game }
    end
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(params[:game])

    params[:user_ids].unshift(current_user.id)
    team_id = 0

    for user_id in params[:user_ids]
      user = User.find(user_id)
      player = Player.new( :user => user, :team_id => team_id )
      player.money = @game.map.starting_money
      team_id += 1
      @game.players << player
    end


    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render json: @game, status: :created, location: @game }
      else
        format.html { render action: "new" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_unit
    get_game

    response = @game.add_unit!(params[:x].to_i, params[:y].to_i, params[:unit_tag], @player)
    response["money"] = { "team#{@player.team_id}_money" => @player.money }

    respond_to do |format|
      format.json { render json: response.to_json( :include => :unit ) }
    end

#    if @game_unit.class == GameUnit
#      respond_to do |format|
#        format.json { render json: { unit_tag: @game_unit.unit.tag, money: @player.money } }
#      end
#    else
#      respond_to do |format|
#        format.json { render json: { message: @game_unit } }
#      end
#    end
  end

  def move_unit
    get_game

    response = @game.move_unit!(params[:fromX].to_i, params[:fromY].to_i, params[:toX].to_i, params[:toY].to_i, @player)

    respond_to do |format|
      format.json { render json: response.to_json( :include => :unit ) }
    end
  end

  def end_turn
    get_game
    @game.end_turn!
    redirect_to @game
  end

  private
  def get_game
    @game = Game.find(params[:id], :include => [{:map => :tiles}])
    @player = @game.player_from_user(current_user)
    raise "Not your turn!" if @player != @game.current_player
  end

end
