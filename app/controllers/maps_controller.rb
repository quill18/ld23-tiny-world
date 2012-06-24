class MapsController < ApplicationController
  # GET /maps
  # GET /maps.json
  def index

    per_page= 20

    if current_user.nil?
      @maps = Map.where(:real_map_id => nil, :published => true).includes(:user).order("vote_total DESC").paginate(:page => params[:page], :per_page => per_page)
    else
      # Only display my maps on the first page
      # Currently the first page will have more entries than per_page if the user has maps
      # We can change per_page on page #1 to correct this, but then page 2 will skip
      # some maps innapropriately unless we fiddle with offsets or something.
      if params[:page].nil? or params[:page].to_i == 1
        @my_maps = Map.where(:real_map_id => nil).where("user_id = #{current_user.id}").includes(:user).order("vote_total DESC")
      end

      @maps = Map.where(:real_map_id => nil, :published => true).where("user_id <> #{current_user.id}").includes(:user).order("vote_total DESC").paginate(:page => params[:page], :per_page => per_page)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @maps }
    end
  end

  def for_user
    @maps = Map.where(:user_id => params[:id])

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @maps }
    end
  end

  # GET /maps/1
  # GET /maps/1.json
  def show
    @map = Map.find(params[:id], :include => "tiles")

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @map }
    end
  end

  # GET /maps/new
  # GET /maps/new.json
  def new
    @map = Map.new
    @map.user = current_user

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @map }
    end
  end

  # GET /maps/1/edit
  def edit
    get_map
  end

  # POST /maps
  # POST /maps.json
  def create
    @map = Map.new(params[:map])
    @map.user = current_user

    respond_to do |format|
      if @map.save
        # User automatically self-upvotes on creation
        map_vote = MapVote.find_or_create_by_map_id_and_user_id(@map.id, current_user.id)
        map_vote.vote = 1
        map_vote.save!
        @map.update_vote_total!

        format.html { redirect_to @map, notice: 'Map was successfully created.' }
        format.json { render json: @map, status: :created, location: @map }
      else
        format.html { render action: "new" }
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /maps/1
  # PUT /maps/1.json
  def update
    get_map

    respond_to do |format|
      if @map.update_attributes(params[:map])
        format.html { redirect_to @map, notice: 'Map was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /maps/1
  # DELETE /maps/1.json
  def destroy
    get_map
    @map.destroy

    respond_to do |format|
      format.html { redirect_to maps_url }
      format.json { head :no_content }
    end
  end

  def publish
    get_map
    @map.published = true
    @map.save!
		if params[:index] == "true"
			redirect_to maps_url
		else
    	redirect_to @map
		end
  end

  def unpublish
    get_map
    @map.published = false
    @map.save!
		if params[:index] == "true"
			redirect_to maps_url
		else
    	redirect_to @map
		end
  end

  def vote
    @map = Map.find(params[:id])
    vote = params[:vote].to_i
    if vote > 0
      vote = 1
    elsif vote < 0
      vote = -1
    else
      vote = 0
    end

    map_vote = MapVote.find_or_create_by_map_id_and_user_id(@map.id, current_user.id)
    if map_vote.vote == vote
      vote = 0
    end

    map_vote.vote = vote
    map_vote.save!

    @map.update_vote_total!

    render :partial => "map_info_inner", :locals => { :map => @map }
  end

  private
  def get_map
    @map = Map.find(params[:id], :include => "tiles")
    raise "Can't change someone else's map!" if @map.user != current_user
    raise "This map is a clone for a game and can't be modified" unless @map.real_map_id.nil?
    return @map
  end
end
