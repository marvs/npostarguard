class NationsController < ApplicationController
  filter_access_to :all
  
  before_filter :set_main_menu_id
  
  def set_main_menu_id
    @main_menu_id = "nations"
  end
  
  def index
    @search = Nation.ascend_by_name.search(params[:search])
    @nations = @search.paginate(:per_page => AppConfig.pagination_limit, :page => params[:page])
  end
  
  def show
    @nation = Nation.find(params[:id])
    @ranking = @nation.latest_ranking
    #@mc = @nation.master_coordinate
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true,:map_type => true)
    @map.center_zoom_init([21.2894,11.9531],1)
    @map.overlay_init(GMarker.new([@ranking.longitude,@ranking.latitude],:title =>"#{@nation.name}", :info_window =>"#{@nation.name}<br/>YOU ARE HERE", :draggable => true))
    @map.icon_global_init( GIcon.new( :image => "/images/nation_colors/red_capital.png", :icon_size => GSize.new( 25,25 ), :icon_anchor => GPoint.new(17,25), :info_window_anchor => GPoint.new(20,5)), "cn_icon" )
    cn_icon = Variable.new("cn_icon")
    #if @mc
    #  @map.record_init @map.add_overlay(GMarker.new([@mc.latitude, @mc.longitude],:title =>"Expected Coordinates", :info_window =>"YOU SHOULD BE HERE", :icon => cn_icon))
    #  @map.overlay_init(GPolyline.new([[@ranking.longitude,@ranking.latitude],[@mc.latitude, @mc.longitude]]))
    #end
  end
  
  def show_coords
    @nation = Nation.find_by_cn_id(params[:cn_id])
    @ranking = @nation.latest_ranking
    @mc = @nation.master_coordinate
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true,:map_type => true)
    @map.center_zoom_init([21.2894,11.9531],1)
    @map.overlay_init(GMarker.new([@ranking.longitude,@ranking.latitude],:title =>"#{@nation.name}", :info_window =>"#{@nation.name}<br/>YOU ARE HERE", :draggable => true))
    @map.icon_global_init( GIcon.new( :image => "/images/nation_colors/red_capital.png", :icon_size => GSize.new( 25,25 ), :icon_anchor => GPoint.new(17,25), :info_window_anchor => GPoint.new(20,5)), "cn_icon" )
    cn_icon = Variable.new("cn_icon")
    if @mc
      @map.record_init @map.add_overlay(GMarker.new([@mc.latitude, @mc.longitude],:title =>"Expected Coordinates", :info_window =>"YOU SHOULD BE HERE", :icon => cn_icon))
      @map.overlay_init(GPolyline.new([[@ranking.longitude,@ranking.latitude],[@mc.latitude, @mc.longitude]]))
    end
  end
  
  def new
    @nation = Nation.new
  end
  
  def create
    @nation = Nation.new(params[:nation])
    if @nation.save
      flash[:notice] = "Successfully created nation."
      redirect_to @nation
    else
      render :action => 'new'
    end
  end
  
  def edit
    @nation = Nation.find(params[:id])
  end
  
  def update
    @nation = Nation.find(params[:id])
    if @nation.update_attributes(params[:nation])
      flash[:notice] = "Successfully updated nation."
      redirect_to @nation
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @nation = Nation.find(params[:id])
    @nation.destroy
    flash[:notice] = "Successfully destroyed nation."
    redirect_to nations_url
  end
end
