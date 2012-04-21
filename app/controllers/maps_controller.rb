class MapsController < ApplicationController
  # GET /maps
  # GET /maps.json
  def index
    @maps = Map.where(:real_map_id => nil)

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
    @map = Map.find(params[:id])

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

  private
  def get_map
    @map = Map.find(params[:id], :include => "tiles")
    raise "Can't change someone else's map!" if @map.user != current_user
    raise "This map is a clone for a game and can't be modified" unless @map.real_map_id.nil?
    return @map
  end
end
