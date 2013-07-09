class CoordinateGroupsController < ApplicationController
  filter_access_to :all
  before_filter :set_main_menu_id
  
  def set_main_menu_id
    @main_menu_id = "starguards"
  end

  def index
    @coordinate_groups = CoordinateGroup.all
  end
  
  def show
    @coordinate_group = CoordinateGroup.find(params[:id])
  end
  
  def new
    @coordinate_group = CoordinateGroup.new
  end
  
  def create
    @coordinate_group = CoordinateGroup.new(params[:coordinate_group])
    if @coordinate_group.save
      flash[:notice] = "Successfully created coordinate group."
      redirect_to @coordinate_group
    else
      render :action => 'new'
    end
  end
  
  def edit
    @coordinate_group = CoordinateGroup.find(params[:id])
  end
  
  def update
    @coordinate_group = CoordinateGroup.find(params[:id])
    if @coordinate_group.update_attributes(params[:coordinate_group])
      flash[:notice] = "Successfully updated coordinate group."
      redirect_to @coordinate_group
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @coordinate_group = CoordinateGroup.find(params[:id])
    @coordinate_group.destroy
    flash[:notice] = "Successfully destroyed coordinate group."
    redirect_to coordinate_groups_url
  end
end
