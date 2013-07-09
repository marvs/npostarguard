class MasterCoordinatesController < ApplicationController
  filter_access_to :all
  
  before_filter :set_main_menu_id
  
  def set_main_menu_id
    @main_menu_id = "starguards"
  end

  def index
    @master_coordinates = MasterCoordinate.find(:all, :order => "rank asc")
  end
  
  def show
    @master_coordinate = MasterCoordinate.find(params[:id])
  end
  
  def new
    @master_coordinate = MasterCoordinate.new
    @coordinate_groups = CoordinateGroup.all
    @nations = Nation.npo_nations
  end
  
  def create
    @master_coordinate = MasterCoordinate.new(params[:master_coordinates])
    @coordinate_groups = CoordinateGroup.all
    @nations = Nation.npo_nations
    if @master_coordinate.save
      flash[:notice] = "Successfully created master coordinates."
      redirect_to @master_coordinate
    else
      render :action => 'new'
    end
  end
  
  def edit
    @master_coordinate = MasterCoordinate.find(params[:id])
    @coordinate_groups = CoordinateGroup.all
    @nations = Nation.npo_nations
  end
  
  def update
    @master_coordinate = MasterCoordinate.find(params[:id])
    @coordinate_groups = CoordinateGroup.all
    @nations = Nation.npo_nations
    if @master_coordinate.update_attributes(params[:master_coordinate])
      flash[:notice] = "Successfully updated master coordinates."
      redirect_to master_coordinates_path
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @master_coordinate = MasterCoordinate.find(params[:id])
    @master_coordinate.destroy
    flash[:notice] = "Successfully destroyed master coordinates."
    redirect_to master_coordinates_url
  end
end
