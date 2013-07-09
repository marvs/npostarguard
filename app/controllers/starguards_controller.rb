require 'rubygems'
require 'hpricot'
require 'open-uri'

# Coords Regex
# /createMarker\(new\s+GPoint\([-]?[0-9]*\.?[0-9]*[,][-]?[0-9]*\.?[0-9]+/
# /createMarker\(new\s+GPoint\(\s?-?[0-9]*\.?[0-9]*,-?[0-9]*\.?[0-9]+/
# /createMarker\(new\s+GPoint\(/    - stripper

# Center Regex
# /map\.centerAndZoom\(new\s+GPoint\(\s?-?[0-9]*\.?[0-9]*,\s+-?[0-9]*\.?[0-9]+/

class StarguardsController < ApplicationController
  filter_access_to :all
  
  before_filter :set_main_menu_id
  
  def set_main_menu_id
    @main_menu_id = "starguards"
  end
  
  def scan_alliance_map
    
  end
  
  def preview_master_list
    @starguard = Starguard.new
    @html_input = params[:map_scan][:html_input]
    @starguard.user = current_user
    
    latitudes = Array.new
    longitudes = Array.new
    nation_names = Array.new
    ruler_names = Array.new
    nation_strengths = Array.new
    nation_ids = Array.new
    nation_colors = Array.new
    
    @doc = Hpricot(@html_input)
    @alliance = (@doc/"table/tr/td/p[@align='center']/b").first
    @alliance = @alliance.inner_text if @alliance
    @starguard.alliance = @alliance
    (@doc/"script").each do |scr|
      if scr.inner_text.include?("map.centerAndZoom")
        raw_center = scr.inner_text.scan(Regexp.new(AppConfig.center_regex))
        raw_center = raw_center[0].gsub(Regexp.new(AppConfig.center_stripper),'')
        @center = { :latitude => raw_center.split(",")[0], :longitude => raw_center.split(",")[1] }
      end
      if scr.inner_text.include?("Nation_ID")
        # Coordinates
        raw_coord = scr.inner_text.scan(Regexp.new(AppConfig.coords_regex))[0]
        if raw_coord.nil?
          # -- thingy
          raw_coord = scr.inner_text.scan(Regexp.new(AppConfig.coords_regex2))[0]
          raw_coord = raw_coord.gsub(Regexp.new(AppConfig.coords_stripper2),'')
        else
          raw_coord = raw_coord.gsub(Regexp.new(AppConfig.coords_stripper),'')
        end
        latitudes << raw_coord.split(",")[1].to_d
        longitudes << raw_coord.split(",")[0].to_d
        # Nation Name
        raw_name = scr.inner_text.scan(Regexp.new(AppConfig.name_regex))
        raw_name = raw_name[0].gsub("Nation Name: ",'') if raw_name[0]
        nation_names << (Hpricot(raw_name)/"a")[0].inner_text if raw_name[0]
        # Ruler Name
        ruler_names << (Hpricot(raw_name)/"a")[1].inner_text if raw_name[0]
        # Strength
        raw_strength = scr.inner_text.scan(Regexp.new(AppConfig.strength_regex))
        nation_strengths << raw_strength[0].gsub("Strength: ",'') if raw_strength[0]
        # Nation ID
        raw_id = raw_name.scan(Regexp.new(AppConfig.nation_id_regex)) if raw_name.class == String
        nation_ids << raw_id[0].gsub("Nation_ID=",'') if raw_id.class == Array and raw_id[0]
        # Nation Color
        raw_color = scr.inner_text.scan(/capital_[A-Z][a-z]+/)
        nation_colors << raw_color[0].gsub("capital_",'').underscore if raw_color[0]
      end
    end
    
    @data_counters = [latitudes.size, longitudes.size, nation_names.size, 
            ruler_names.size, nation_strengths.size, nation_ids.size, nation_colors.size] 
    if @data_counters.uniq.size == 1 and @data_counters.uniq.first != 0
      @data_count = @data_counters.first.to_i
      # Generate Rankings and Nations
      @data_count.times do |cindex|
        nation = Nation.find_by_cn_id(nation_ids[cindex])
        if nation
          temp_nation_id = nation.id
        end
        # Generate Rankings
        @starguard.starguard_rankings.build( 
              :nation_id => temp_nation_id,
              :rank => cindex + 1,
              :strength => nation_strengths[cindex].gsub(",",'').to_f,
              :color => nation_colors[cindex],
              :latitude => latitudes[cindex].to_f,
              :longitude => longitudes[cindex].to_f )
      end
      if @starguard.valid?
        flash[:notice] = "Successful parse."
        @rankings = @starguard.starguard_rankings
        @coordinate_groups = CoordinateGroup.all
        @not_assigned_nations = Array.new
        @rankings.each do |rank|
          if rank.nation
            unless rank.nation.master_coordinate
              @not_assigned_nations << rank.nation
            end
          end
        end
      else
        flash[:notice] = "Unable to save Top 100 List"
        redirect_to :action => "scan_alliance_map"
      end
    else
      @data = []
      flash[:error] = "Parsed HTML input is not valid!<br/>"
      flash[:error] << "LAT - LON - NAT - RUL - STR - IDS - COL<br/>"
      flash[:error] << @data_counters.join(" - ")
      redirect_to :action => "scan_alliance_map"
    end
    
  end
  
  def preview_master_list_old
    @html_input = params[:map_scan][:html_input]
    @user = User.find_by_id(params[:map_scan][:user_id])
    @starguard = Starguard.new
    
    latitudes = Array.new
    longitudes = Array.new
    nation_names = Array.new
    ruler_names = Array.new
    nation_strengths = Array.new
    nation_ids = Array.new
    nation_colors = Array.new
    
    @doc = Hpricot(@html_input)
    @alliance = (@doc/"table/tr/td/p[@align='center']/b").first
    @alliance = @alliance.inner_text if @alliance
    (@doc/"script").each do |scr|
      if scr.inner_text.include?("map.centerAndZoom")
        raw_center = scr.inner_text.scan(Regexp.new(AppConfig.center_regex))
        raw_center = raw_center[0].gsub(Regexp.new(AppConfig.center_stripper),'')
        @center = { :latitude => raw_center.split(",")[0], :longitude => raw_center.split(",")[1] }
      end
      if scr.inner_text.include?("Nation_ID")
        # Coordinates
        raw_coord = scr.inner_text.scan(Regexp.new(AppConfig.coords_regex))[0]
        if raw_coord.nil?
          # -- thingy
          raw_coord = scr.inner_text.scan(Regexp.new(AppConfig.coords_regex2))[0]
          raw_coord = raw_coord.gsub(Regexp.new(AppConfig.coords_stripper2),'')
        else
          raw_coord = raw_coord.gsub(Regexp.new(AppConfig.coords_stripper),'')
        end
        latitudes << raw_coord.split(",")[1].to_d
        longitudes << raw_coord.split(",")[0].to_d
        # Nation Name
        raw_name = scr.inner_text.scan(Regexp.new(AppConfig.name_regex))
        raw_name = raw_name[0].gsub("Nation Name: ",'') if raw_name[0]
        nation_names << (Hpricot(raw_name)/"a")[0].inner_text if raw_name[0]
        # Ruler Name
        ruler_names << (Hpricot(raw_name)/"a")[1].inner_text if raw_name[0]
        # Strength
        raw_strength = scr.inner_text.scan(Regexp.new(AppConfig.strength_regex))
        nation_strengths << raw_strength[0].gsub("Strength: ",'') if raw_strength[0]
        # Nation ID
        raw_id = raw_name.scan(Regexp.new(AppConfig.nation_id_regex)) if raw_name.class == String
        nation_ids << raw_id[0].gsub("Nation_ID=",'') if raw_id.class == Array and raw_id[0]
        # Nation Color
        raw_color = scr.inner_text.scan(/capital_[A-Z][a-z]+/)
        nation_colors << raw_color[0].gsub("capital_",'').underscore if raw_color[0]
      end
    end
    
    @data_counters = [latitudes.size, longitudes.size, nation_names.size, 
            ruler_names.size, nation_strengths.size, nation_ids.size, nation_colors.size] 
    if @data_counters.uniq.size == 1 and @data_counters.uniq.first != 0
      @data_count = @data_counters.first.to_i
      # Generate Data
      @data = Array.new(@data_count)
      @data_count.times do |cindex|
        @data[cindex] = { :latitude => latitudes[cindex], 
            :longitude => longitudes[cindex],
            :nation_name => nation_names[cindex],
            :ruler_name => ruler_names[cindex],
            :strength => nation_strengths[cindex],
            :nation_id => nation_ids[cindex],
            :color => nation_colors[cindex] }
      end
    else
      @data = []
      flash[:error] = "Parsed HTML input is not valid!<br/>"
      flash[:error] << "LAT - LON - NAT - RUL - STR - IDS - COL<br/>"
      flash[:error] << @data_counters.join(" - ")
      redirect_to :action => "scan_alliance_map"
    end
    
  end
  
  def index
    @search = Starguard.descend_by_created_at.search(params[:search])
    @starguards = @search.paginate(:per_page => AppConfig.pagination_limit, :page => params[:page])
    @users = User.all
  end
  
  def show
    @starguard = Starguard.find(params[:id])
    @rankings = @starguard.starguard_rankings
    @coordinate_groups = CoordinateGroup.all
    @not_assigned_nations = Array.new
    @rankings.each do |rank|
      unless rank.nation.master_coordinate
        @not_assigned_nations << rank.nation
      end
    end
    @ranges = Array.new
    @ranges << [0,15] # North Arm
    @ranges << [16,31] # North-East Arm
    @ranges << [32,47] # South-East Arm
    @ranges << [48,63] # South-West Arm
    @ranges << [64,79] # North-West Arm
    @ranges << [80,99] # Remaining 
  end
  
  def show_by_ranking
    @starguard = Starguard.find(params[:id])
    @rankings = @starguard.starguard_rankings
    @coordinate_groups = CoordinateGroup.all
    @ranges = Array.new
    @ranges << [0,15] # North Arm
    @ranges << [16,31] # North-East Arm
    @ranges << [32,47] # South-East Arm
    @ranges << [48,63] # South-West Arm
    @ranges << [64,79] # North-West Arm
    @ranges << [80,99] # Remaining 
  end
  
  def star_design
    # Default Values
    @n_point  = AppConfig.n_point
    @nw_join  = AppConfig.nw_join
    @nw_point = AppConfig.nw_point
    @sw_join  = AppConfig.sw_join
    @sw_point = AppConfig.sw_point
    @s_join   = AppConfig.s_join
    @se_point = AppConfig.se_point
    @se_join  = AppConfig.se_join
    @ne_point = AppConfig.ne_point
    @ne_join  = AppConfig.ne_join
    # Inputted Coords
    if params[:coords]
      @n_point  = [params[:coords][:n_point_lat].to_f, params[:coords][:n_point_long].to_f]
      @nw_join = [params[:coords][:nw_join_lat].to_f, params[:coords][:nw_join_long].to_f]
      @nw_point = [params[:coords][:nw_point_lat].to_f, params[:coords][:nw_point_long].to_f]
      @sw_join = [params[:coords][:sw_join_lat].to_f, params[:coords][:sw_join_long].to_f]
      @sw_point = [params[:coords][:sw_point_lat].to_f, params[:coords][:sw_point_long].to_f]
      @s_join  = [params[:coords][:s_join_lat].to_f, params[:coords][:s_join_long].to_f]
      @se_point = [params[:coords][:se_point_lat].to_f, params[:coords][:se_point_long].to_f]
      @se_join = [params[:coords][:se_join_lat].to_f, params[:coords][:se_join_long].to_f]
      @ne_point  = [params[:coords][:ne_point_lat].to_f, params[:coords][:ne_point_long].to_f]
      @ne_join = [params[:coords][:ne_join_lat].to_f, params[:coords][:ne_join_long].to_f]
    end
    @map = GMap.new("star_div")
    @map.control_init(:large_map => true,:map_type => true)
    @map.center_zoom_init([21.2894,11.9531],1)
    polygon = GPolygon.new([@n_point,@nw_join,@nw_point,@sw_join,@sw_point,@s_join,@se_point,@se_join,@ne_point,@ne_join,@n_point],"#FF0000",3,1.0,"#FF0000",0.2)
    @map.overlay_init(polygon)
    
    @forum_code = "[list=1]\n"
    @forum_code << "[*] [b]North Point:[/b] #{@n_point[0]} , #{@n_point[1]}\n"
    @forum_code << "[*] [b]North-West Join:[/b] #{@nw_join[0]} , #{@nw_join[1]}\n"
    @forum_code << "[*] [b]North-West Point:[/b] #{@nw_point[0]} , #{@nw_point[1]}\n"
    @forum_code << "[*] [b]South-West Join:[/b] #{@sw_join[0]} , #{@sw_join[1]}\n"
    @forum_code << "[*] [b]South-West Point:[/b] #{@sw_point[0]} , #{@sw_point[1]}\n"
    @forum_code << "[*] [b]South Join:[/b] #{@s_join[0]} , #{@s_join[1]}\n"
    @forum_code << "[*] [b]South-East Point:[/b] #{@se_point[0]} , #{@se_point[1]}\n"
    @forum_code << "[*] [b]South-East Join:[/b] #{@se_join[0]} , #{@se_join[1]}\n"
    @forum_code << "[*] [b]North-East Point:[/b] #{@ne_point[0]} , #{@ne_point[1]}\n"
    @forum_code << "[*] [b]North-East Join:[/b] #{@ne_join[0]} , #{@ne_join[1]}\n"
    @forum_code << "[/list]"
    
    @points_list = Array.new
    (1..10).each do |i|
      @points_list << ["#{i*10} Nations", i*10]
    end
  end
  
  def star_points
    # Default Values
    @n_point  = AppConfig.n_point
    @nw_join  = AppConfig.nw_join
    @nw_point = AppConfig.nw_point
    @sw_join  = AppConfig.sw_join
    @sw_point = AppConfig.sw_point
    @s_join   = AppConfig.s_join
    @se_point = AppConfig.se_point
    @se_join  = AppConfig.se_join
    @ne_point = AppConfig.ne_point
    @ne_join  = AppConfig.ne_join
    @total_points = 80
    @rank_points = Array.new(@total_points+1)
    @rank_points.each do |r|
      @rank_points = {}
    end
    @forum_code = ""
    # Inputted Coords
    if params[:coords]
      @n_point  = [params[:coords][:n_point_lat].to_f, params[:coords][:n_point_long].to_f]
      @nw_join = [params[:coords][:nw_join_lat].to_f, params[:coords][:nw_join_long].to_f]
      @nw_point = [params[:coords][:nw_point_lat].to_f, params[:coords][:nw_point_long].to_f]
      @sw_join = [params[:coords][:sw_join_lat].to_f, params[:coords][:sw_join_long].to_f]
      @sw_point = [params[:coords][:sw_point_lat].to_f, params[:coords][:sw_point_long].to_f]
      @s_join  = [params[:coords][:s_join_lat].to_f, params[:coords][:s_join_long].to_f]
      @se_point = [params[:coords][:se_point_lat].to_f, params[:coords][:se_point_long].to_f]
      @se_join = [params[:coords][:se_join_lat].to_f, params[:coords][:se_join_long].to_f]
      @ne_point  = [params[:coords][:ne_point_lat].to_f, params[:coords][:ne_point_long].to_f]
      @ne_join = [params[:coords][:ne_join_lat].to_f, params[:coords][:ne_join_long].to_f]
      @total_points = params[:coords][:total_points].to_i
    end
    @arm_points = @total_points/10
    @map = GMap.new("star_points")
    @map.control_init(:large_map => true,:map_type => true)
    @map.center_zoom_init([21.2894,11.9531],1)
    @map.icon_global_init( GIcon.new( :image => "/images/nation_colors/red_capital.png", :icon_size => GSize.new( 25,25 ), :icon_anchor => GPoint.new(17,25), :info_window_anchor => GPoint.new(20,5)), "cn_icon" )
    cn_icon = Variable.new("cn_icon")
    # North Arm
    # Compute nw_join, n_point, ne_join
    @forum_code << "[b]North Arm:[/b]\n"
    @forum_code << "[b]North-West Join -> North Point -> North-East Join:[/b]\n"
    @diff_lat = (@nw_join[0] - @n_point[0])/@arm_points
    @diff_long = (@nw_join[1] - @n_point[1])/@arm_points
    (@arm_points).times do |count|
      @rank_points[count+1] = { :latitude => @nw_join[0]-(@diff_lat*(count)), :longitude => @nw_join[1]-(@diff_long*(count)) }
      @forum_code << "Point #{count+1}: Latitude: #{@rank_points[count+1][:latitude]}  Longitude: #{@rank_points[count+1][:longitude]}\n"
      @map.record_init @map.add_overlay(GMarker.new([@rank_points[count+1][:latitude],@rank_points[count+1][:longitude]],:title =>"Point #{count+1}", :info_window =>"North Arm<br/>Point #{count+1}", :icon => cn_icon))
    end
    @diff_lat = (@n_point[0] - @ne_join[0])/@arm_points
    @diff_long = (@n_point[1] - @ne_join[1])/@arm_points
    @start_count = @arm_points + 1
    (@arm_points).times do |count|
      @rank_points[count+@start_count] = { :latitude => @n_point[0]-(@diff_lat*(count)), :longitude => @n_point[1]-(@diff_long*(count)) }
      @forum_code << "Point #{count+@start_count}: Latitude: #{@rank_points[count+@start_count][:latitude]}  Longitude: #{@rank_points[count+@start_count][:longitude]}\n"
      @map.record_init @map.add_overlay(GMarker.new([@rank_points[count+@start_count][:latitude],@rank_points[count+@start_count][:longitude]],:title =>"Point #{count+@start_count}", :info_window =>"North Arm<br/>Point #{count+@start_count}", :icon => cn_icon))
    end
    
    # North-East Arm
    # Compute ne_join, ne_point, se_join
    @forum_code << "\n\n"
    @forum_code << "[b]North-East Arm:[/b]\n"
    @forum_code << "[b]North-East Join -> North-East Point -> South-East Join:[/b]\n"
    @diff_lat = (@ne_join[0] - @ne_point[0])/@arm_points
    @diff_long = (@ne_join[1] - @ne_point[1])/@arm_points
    @start_count = (@arm_points*2) + 1
    (@arm_points).times do |count|
      @rank_points[count+@start_count] = { :latitude => @ne_join[0]-(@diff_lat*(count)), :longitude => @ne_join[1]-(@diff_long*(count)) }
      @forum_code << "Point #{count+@start_count}: Latitude: #{@rank_points[count+@start_count][:latitude]}  Longitude: #{@rank_points[count+@start_count][:longitude]}\n"
      @map.record_init @map.add_overlay(GMarker.new([@rank_points[count+@start_count][:latitude],@rank_points[count+@start_count][:longitude]],:title =>"Point #{count+@start_count}", :info_window =>"North-East Arm<br/>Point #{count+@start_count}", :icon => cn_icon))
    end
    @diff_lat = (@ne_point[0] - @se_join[0])/@arm_points
    @diff_long = (@ne_point[1] - @se_join[1])/@arm_points
    @start_count = (@arm_points*3) + 1
    (@arm_points).times do |count|
      @rank_points[count+@start_count] = { :latitude => @ne_point[0]-(@diff_lat*(count)), :longitude => @ne_point[1]-(@diff_long*(count)) }
      @forum_code << "Point #{count+@start_count}: Latitude: #{@rank_points[count+@start_count][:latitude]}  Longitude: #{@rank_points[count+@start_count][:longitude]}\n"
      @map.record_init @map.add_overlay(GMarker.new([@rank_points[count+@start_count][:latitude],@rank_points[count+@start_count][:longitude]],:title =>"Point #{count+@start_count}", :info_window =>"North-East Arm<br/>Point #{count+@start_count}", :icon => cn_icon))
    end
    
    # South-East Arm
    # Compute se_join, se_point, s_join
    @forum_code << "\n\n"
    @forum_code << "[b]South-East Arm:[/b]\n"
    @forum_code << "[b]South-East Join -> South-East Point -> South Join:[/b]\n"
    @diff_lat = (@se_join[0] - @se_point[0])/@arm_points
    @diff_long = (@se_join[1] - @se_point[1])/@arm_points
    @start_count = (@arm_points*4) + 1
    (@arm_points).times do |count|
      @rank_points[count+@start_count] = { :latitude => @se_join[0]-(@diff_lat*(count)), :longitude => @se_join[1]-(@diff_long*(count)) }
      @forum_code << "Point #{count+@start_count}: Latitude: #{@rank_points[count+@start_count][:latitude]}  Longitude: #{@rank_points[count+@start_count][:longitude]}\n"
      @map.record_init @map.add_overlay(GMarker.new([@rank_points[count+@start_count][:latitude],@rank_points[count+@start_count][:longitude]],:title =>"Point #{count+@start_count}", :info_window =>"South-East Arm<br/>Point #{count+@start_count}", :icon => cn_icon))
    end
    @diff_lat = (@se_point[0] - @s_join[0])/@arm_points
    @diff_long = (@se_point[1] - @s_join[1])/@arm_points
    @start_count = (@arm_points*5) + 1
    (@arm_points).times do |count|
      @rank_points[count+@start_count] = { :latitude => @se_point[0]-(@diff_lat*(count)), :longitude => @se_point[1]-(@diff_long*(count)) }
      @forum_code << "Point #{count+@start_count}: Latitude: #{@rank_points[count+@start_count][:latitude]}  Longitude: #{@rank_points[count+@start_count][:longitude]}\n"
      @map.record_init @map.add_overlay(GMarker.new([@rank_points[count+@start_count][:latitude],@rank_points[count+@start_count][:longitude]],:title =>"Point #{count+@start_count}", :info_window =>"South-East Arm<br/>Point #{count+@start_count}", :icon => cn_icon))
    end
    
    # South-West Arm
    # Compute s_join, sw_point, sw_join
    @forum_code << "\n\n"
    @forum_code << "[b]South-West Arm:[/b]\n"
    @forum_code << "[b]South Join -> South-West Point -> South-West Join:[/b]\n"
    @diff_lat = (@s_join[0] - @sw_point[0])/@arm_points
    @diff_long = (@s_join[1] - @sw_point[1])/@arm_points
    @start_count = (@arm_points*6) + 1
    (@arm_points).times do |count|
      @rank_points[count+@start_count] = { :latitude => @s_join[0]-(@diff_lat*(count)), :longitude => @s_join[1]-(@diff_long*(count)) }
      @forum_code << "Point #{count+@start_count}: Latitude: #{@rank_points[count+@start_count][:latitude]}  Longitude: #{@rank_points[count+@start_count][:longitude]}\n"
      @map.record_init @map.add_overlay(GMarker.new([@rank_points[count+@start_count][:latitude],@rank_points[count+@start_count][:longitude]],:title =>"Point #{count+@start_count}", :info_window =>"South-West Arm<br/>Point #{count+@start_count}", :icon => cn_icon))
    end
    @diff_lat = (@sw_point[0] - @sw_join[0])/@arm_points
    @diff_long = (@sw_point[1] - @sw_join[1])/@arm_points
    @start_count = (@arm_points*7) + 1
    (@arm_points).times do |count|
      @rank_points[count+@start_count] = { :latitude => @sw_point[0]-(@diff_lat*(count)), :longitude => @sw_point[1]-(@diff_long*(count)) }
      @forum_code << "Point #{count+@start_count}: Latitude: #{@rank_points[count+@start_count][:latitude]}  Longitude: #{@rank_points[count+@start_count][:longitude]}\n"
      @map.record_init @map.add_overlay(GMarker.new([@rank_points[count+@start_count][:latitude],@rank_points[count+@start_count][:longitude]],:title =>"Point #{count+@start_count}", :info_window =>"South-West Arm<br/>Point #{count+@start_count}", :icon => cn_icon))
    end
    
    # North-West Arm
    # Compute sw_join, nw_point, nw_join
    @forum_code << "\n\n"
    @forum_code << "[b]North-West Arm:[/b]\n"
    @forum_code << "[b]South-West Join -> North-West Point -> North-West Join:[/b]\n"
    @diff_lat = (@sw_join[0] - @nw_point[0])/@arm_points
    @diff_long = (@sw_join[1] - @nw_point[1])/@arm_points
    @start_count = (@arm_points*8) + 1
    (@arm_points).times do |count|
      @rank_points[count+@start_count] = { :latitude => @sw_join[0]-(@diff_lat*(count)), :longitude => @sw_join[1]-(@diff_long*(count)) }
      @forum_code << "Point #{count+@start_count}: Latitude: #{@rank_points[count+@start_count][:latitude]}  Longitude: #{@rank_points[count+@start_count][:longitude]}\n"
      @map.record_init @map.add_overlay(GMarker.new([@rank_points[count+@start_count][:latitude],@rank_points[count+@start_count][:longitude]],:title =>"Point #{count+@start_count}", :info_window =>"North-West Arm<br/>Point #{count+@start_count}", :icon => cn_icon))
    end
    @diff_lat = (@nw_point[0] - @nw_join[0])/@arm_points
    @diff_long = (@nw_point[1] - @nw_join[1])/@arm_points
    @start_count = (@arm_points*9) + 1
    (@arm_points).times do |count|
      @rank_points[count+@start_count] = { :latitude => @nw_point[0]-(@diff_lat*(count)), :longitude => @nw_point[1]-(@diff_long*(count)) }
      @forum_code << "Point #{count+@start_count}: Latitude: #{@rank_points[count+@start_count][:latitude]}  Longitude: #{@rank_points[count+@start_count][:longitude]}\n"
      @map.record_init @map.add_overlay(GMarker.new([@rank_points[count+@start_count][:latitude],@rank_points[count+@start_count][:longitude]],:title =>"Point #{count+@start_count}", :info_window =>"North-West Arm<br/>Point #{count+@start_count}", :icon => cn_icon))
    end
    
  end
  
  def nation_message
    @nation = Nation.find_by_cn_id(params[:cn_id])
    @ranking = @nation.latest_ranking
    @mc = @nation.master_coordinate
    @message = "Hello #{@nation.ruler},<br/><br/>"
    @message << "You may have noticed the success of the Pacifican project to create Franco's Star and as a member of the New Pacific Order's Top 100 you have a duty to preserve Franco's Star. Please move to these Coordinates:<br/><br/>"
    @message << "Latitude: #{@mc.latitude}<br/>Longitude: #{@mc.longitude}<br/><br/>"
    @message << "Please use this Guide provided by the Star Guard:<br/><br/>"
    @message << "http://pacificorder.net/forum/index.php?showtopic=110500"
    @message << "<br/><br/>Here's the URL mentioned in the Guide:<br/>"
    @message << "http://www.cybernations.net/nation_drill_display_map.asp?shownation=#{@nation.cn_id}&lon=#{@mc.longitude}&lat=#{@mc.latitude}&VALUE=####"
    @message << "<br/><br/>"
    @message << "If you have any queries feel free to contact me in game, on the forums or on IRC. If your nation is situated for role playing reasons, and is unable to move, please reply as such.<br/><br/>"
    @message << "Yours,<br/>"
    @message << current_user.username
    @message << "<br/>NPO Star Guard"
  end
  
  def nation_thanks_message
    @nation = Nation.find_by_cn_id(params[:cn_id])
    @ranking = @nation.latest_ranking
    @mc = @nation.master_coordinate
    @message = "Greetings #{@nation.ruler},<br/><br/>"
    @message << "We members of the Star Guard would like to express our gratitude to you, member of the New Pacific Orders' largest nations, for joining us in the eternal task of keeping Franco's Star in its honorable shape.<br/><br/>"
    @message << "We wish to present this userbar to you to signify that you are part of the esteemed Franco's Star.<br/><br/>"
    @message << "<a href='http://i34.tinypic.com/xmpyzm.png' target='_blank'>http://i34.tinypic.com/xmpyzm.png</a><br/><br/>"
    @message << "Yours sincerely,<br/>"
    @message << current_user.username
    @message << "<br/>NPO Star Guard"
  end
  
  def forum_code
    @starguard = Starguard.find(params[:id])
    @rankings = @starguard.starguard_rankings
    @coordinate_groups = CoordinateGroup.all
    @not_assigned_nations = Array.new
    @rankings.each do |rank|
      unless rank.nation.master_coordinate
        @not_assigned_nations << rank.nation
      end
    end
    @forum_code = "[size=4]Top 100 List[/size]\n"
    @forum_code << "[size=4]Date: #{@starguard.created_at.to_s(:long)} UTC[/size]\n"
    @forum_code << "[size=4]Prepared By: #{@starguard.user.username}[/size]\n\n"
    
    @coordinate_groups.each do |coordinate_group|
      unless coordinate_group.name == "Unassigned"
        @forum_code << "\n\n[size=3][b]#{coordinate_group.name}[/b][/size]\n"
        @forum_code << "[size=2][b]#{coordinate_group.compliant_message(@starguard)}[/b][/size]\n"
        @forum_code << "[table][row][header][b]Position[/b][/header][header][b]Nation[/b][/header][header][b]Ruler[/b][/header][header][b]Strength[/b][/header][header][b]Latitude[/b][/header][header][b]Longitude[/b][/header][header][b]Link to Give[/b][/header][/row]"
        coordinate_group.master_coordinates.each do |mc|
          @forum_code << "[row][cell]#{mc.rank}[/cell]"
          if mc.nation
            @forum_code << "[cell][url=#{AppConfig.nation_url}#{mc.nation.cn_id}]#{mc.nation.name}[/url][/cell]"
            @forum_code << "[cell][url=#{AppConfig.message_url}#{mc.nation.cn_id}]#{mc.nation.ruler}[/url][/cell]"
            if mc.nation.get_ranking(@starguard)
              @forum_code << "[cell]#{mc.nation.get_ranking(@starguard).strength}[/cell]"
              if Starguard.correct_coordinate(mc.latitude, mc.nation.get_ranking(@starguard).latitude)
                @forum_code << "[cell][color='green']#{mc.nation.get_ranking(@starguard).latitude}[/color]"
              else
                @forum_code << "[cell][color='red']#{mc.nation.get_ranking(@starguard).latitude}[/color]"
              end
              @forum_code << "\nAssigned: #{mc.latitude}[/cell]"
              if Starguard.correct_coordinate(mc.longitude, mc.nation.get_ranking(@starguard).longitude)
                @forum_code << "[cell][color='green']#{mc.nation.get_ranking(@starguard).longitude}[/color]"
              else
                @forum_code << "[cell][color='red']#{mc.nation.get_ranking(@starguard).longitude}[/color]"
              end
              @forum_code << "\nAssigned: #{mc.longitude}[/cell]"
              @forum_code << "[cell][url='http://www.cybernations.net/nation_drill_display_map.asp?shownation=#{mc.nation.cn_id}&lon=#{mc.longitude}&lat=#{mc.latitude}&VALUE=??????'][/url]http://www.cybernations.net/nation_drill_display_map.asp?shownation=#{mc.nation.cn_id}&lon=#{mc.longitude}&lat=#{mc.latitude}&VALUE=??????[/cell]"
            end
          end
          @forum_code << "[/row]"
        end
        @forum_code << "[/table]"
      end
    end
    
    @forum_code << "\n\n[size=3][b]Not Assigned[/b][/size]\n"
    @forum_code << "[table][row][header][b]Nation[/b][/header][header][b]Ruler[/b][/header][header][b]Strength[/b][/header][header][b]Latitude[/b][/header][header][b]Longitude[/b][/header][/row]"
    @not_assigned_nations.each do |nation|
      @forum_code << "[row]"
      @forum_code << "[cell][url=#{AppConfig.nation_url}#{nation.cn_id}]#{nation.name}[/url][/cell]"
      @forum_code << "[cell][url=#{AppConfig.message_url}#{nation.cn_id}]#{nation.ruler}[/url][/cell]"
      @forum_code << "[cell]#{nation.get_ranking(@starguard).strength}[/cell]"
      @forum_code << "[cell]#{nation.get_ranking(@starguard).latitude}[/cell]"
      @forum_code << "[cell]#{nation.get_ranking(@starguard).longitude}[/cell]"
      @forum_code << "[/row]"
    end
    @forum_code << "[/table]"
    
  end
  
  def new
    @starguard = Starguard.new
  end
  
  def create
    @starguard = Starguard.new(params[:starguard])
    @html_input = params[:html][:input]
    
    latitudes = Array.new
    longitudes = Array.new
    nation_names = Array.new
    ruler_names = Array.new
    nation_strengths = Array.new
    nation_ids = Array.new
    nation_colors = Array.new
    
    @doc = Hpricot(@html_input)
    @alliance = (@doc/"table/tr/td/p[@align='center']/b").first
    @alliance = @alliance.inner_text if @alliance
    (@doc/"script").each do |scr|
      if scr.inner_text.include?("map.centerAndZoom")
        raw_center = scr.inner_text.scan(Regexp.new(AppConfig.center_regex))
        raw_center = raw_center[0].gsub(Regexp.new(AppConfig.center_stripper),'')
        @center = { :latitude => raw_center.split(",")[0], :longitude => raw_center.split(",")[1] }
      end
      if scr.inner_text.include?("Nation_ID")
        # Coordinates
        raw_coord = scr.inner_text.scan(Regexp.new(AppConfig.coords_regex))[0]
        if raw_coord.nil?
          # -- thingy
          raw_coord = scr.inner_text.scan(Regexp.new(AppConfig.coords_regex2))[0]
          raw_coord = raw_coord.gsub(Regexp.new(AppConfig.coords_stripper2),'')
        else
          raw_coord = raw_coord.gsub(Regexp.new(AppConfig.coords_stripper),'')
        end
        latitudes << raw_coord.split(",")[1].to_d
        longitudes << raw_coord.split(",")[0].to_d
        # Nation Name
        raw_name = scr.inner_text.scan(Regexp.new(AppConfig.name_regex))
        raw_name = raw_name[0].gsub("Nation Name: ",'') if raw_name[0]
        nation_names << (Hpricot(raw_name)/"a")[0].inner_text if raw_name[0]
        # Ruler Name
        ruler_names << (Hpricot(raw_name)/"a")[1].inner_text if raw_name[0]
        # Strength
        raw_strength = scr.inner_text.scan(Regexp.new(AppConfig.strength_regex))
        nation_strengths << raw_strength[0].gsub("Strength: ",'') if raw_strength[0]
        # Nation ID
        raw_id = raw_name.scan(Regexp.new(AppConfig.nation_id_regex)) if raw_name.class == String
        nation_ids << raw_id[0].gsub("Nation_ID=",'') if raw_id.class == Array and raw_id[0]
        # Nation Color
        raw_color = scr.inner_text.scan(/capital_[A-Z][a-z]+/)
        nation_colors << raw_color[0].gsub("capital_",'').underscore if raw_color[0]
      end
    end
    
    @data_counters = [latitudes.size, longitudes.size, nation_names.size, 
            ruler_names.size, nation_strengths.size, nation_ids.size, nation_colors.size] 
    if @data_counters.uniq.size == 1 and @data_counters.uniq.first != 0
      @data_count = @data_counters.first.to_i
      # Generate Rankings and Nations
      @data_count.times do |cindex|
        nation = Nation.find_by_cn_id(nation_ids[cindex])
        if nation
          if nation.alliance != @alliance
            # Update Nation Alliance
            nation.update_attribute('alliance', @alliance)
          end
        else
          # Generate new Nation
          nation = Nation.new
          nation.cn_id = nation_ids[cindex]
          nation.ruler = ruler_names[cindex]
          nation.name = nation_names[cindex]
          nation.alliance = @alliance
          nation.save
        end
        # Generate Rankings
        @starguard.starguard_rankings.build( 
              :nation_id => nation.id,
              :rank => cindex + 1,
              :strength => nation_strengths[cindex].gsub(",",'').to_f,
              :color => nation_colors[cindex],
              :latitude => latitudes[cindex].to_f,
              :longitude => longitudes[cindex].to_f )
      end
      if @starguard.save
        flash[:notice] = "Successfully created Top 100 List."
        redirect_to @starguard
      else
        flash[:notice] = "Unable to save Top 100 List"
        redirect_to :action => "scan_alliance_map"
      end
    else
      @data = []
      flash[:error] = "Parsed HTML input is not valid!<br/>"
      flash[:error] << "LAT - LON - NAT - RUL - STR - IDS - COL<br/>"
      flash[:error] << @data_counters.join(" - ")
      redirect_to :action => "scan_alliance_map"
    end
    
  end
  
  def edit
    @starguard = Starguard.find(params[:id])
  end
  
  def update
    @starguard = Starguard.find(params[:id])
    if @starguard.update_attributes(params[:starguard])
      flash[:notice] = "Successfully updated starguard."
      redirect_to @starguard
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @starguard = Starguard.find(params[:id])
    @starguard.destroy
    flash[:notice] = "Successfully destroyed starguard."
    redirect_to starguards_url
  end
  
  def parsed_url_method
    @main_menu_id = "home"
    flash[:error] = nil
    flash[:result] = nil
    if params[:map_scan]
      if params[:map_scan][:html_input].blank?
        flash[:error] = "Your input is blank!&nbsp;&nbsp;"
        flash[:error] << "<img src='/images/smileys/smiley-angry009.gif'/>"
      else
        @html_input = params[:map_scan][:html_input]
        
        @doc = Hpricot(@html_input)
        @alliance = (@doc/"table/tr/td/p[@align='center']/b").first
        @alliance = @alliance.inner_text if @alliance
        (@doc/"script").each do |scr|
          if scr.inner_text.include?("Nation_ID")
            @mytext = scr.inner_text
            # Coordinates
            raw_coord = scr.inner_text.scan(Regexp.new(AppConfig.single_coords_regex))[0]
            if raw_coord.nil?
              # -- thingy
              raw_coord = scr.inner_text.scan(Regexp.new(AppConfig.single_coords_regex2))[0]
              raw_coord = raw_coord.gsub(Regexp.new(AppConfig.single_coords_stripper2),'') if raw_coord
            else
              raw_coord = raw_coord.gsub(Regexp.new(AppConfig.single_coords_stripper),'')
            end
            if raw_coord
              @latitude = raw_coord.split(",")[0].to_d
              @longitude = raw_coord.split(",")[1].to_d
            end
            # Nation ID
            raw_id = @mytext.scan(Regexp.new(AppConfig.nation_id_regex))
            @nation_id = raw_id[0].gsub("Nation_ID=",'') if raw_id.class == Array and raw_id[0]
            # Value
            raw_value = @mytext.scan(/\&VALUE=[0-9A-Za-z]*/)
            @nation_value = raw_value[0].gsub("&VALUE=",'') if raw_value.class == Array and raw_value[0]
            if @nation_value.nil?
              if @mytext.scan(/draggable:\sfalse/)[0]
                @not_draggable = true
              end
            end
          end
        end
        
        if @nation_id
          @nation = Nation.find_by_cn_id(@nation_id)
        end
        
        if @latitude and @longitude and @nation
          if @nation.master_coordinate
            @latitude_ok = false
            @longitude_ok = false
            if Starguard.correct_coordinate(@nation.master_coordinate.latitude, @latitude)
              @latitude_ok = true
            end
            if Starguard.correct_coordinate(@nation.master_coordinate.longitude, @longitude)
              @longitude_ok = true
            end
            flash[:result] = "Nation: <strong>#{@nation.name}</strong>"
            flash[:result] << "<br/>Ruler: <strong>#{@nation.ruler}</strong>"
            flash[:result] << "<br/>Current Latitude: <strong>#{@latitude}</strong>"
            flash[:result] << "<br/>Current Longitude: <strong>#{@longitude}</strong><br/>"
            if @latitude_ok and @longitude_ok
              flash[:result] << "<br/>Your nation is within the correct coordinates. Congratulations!"
            else
              if @latitude_ok == false
                flash[:result] << "<br/>Your latitude coordinate is incorrect! Must be <strong>#{@nation.master_coordinate.latitude}</strong>"
              end
              if @longitude_ok == false
                flash[:result] << "<br/>Your longitude coordinate is incorrect! Must be <strong>#{@nation.master_coordinate.longitude}</strong>"
              end
              
              if @nation_value
                move_link = "http://www.cybernations.net/nation_drill_display_map.asp?shownation=#{@nation.cn_id}&lon=#{@nation.master_coordinate.longitude}&lat=#{@nation.master_coordinate.latitude}&VALUE=#{@nation_value}"
                flash[:result] << "<br/><br/>Please click the link below to move your nation:"
                flash[:result] << "<br/><br/><strong><a href=#{move_link} target='_blank'>#{move_link}</a></strong>"
              elsif @nation_value.nil? and @not_draggable
                flash[:result] << "<br/><br/>Your nation has recently moved. You cannot move it as of now."
              end
            end
            #flash[:result] << "<br/><br/><img src='/images/smileys/smiley-devil03.gif'/>"
          else
            flash[:result] = "Sorry, your Nation is not included in Franco's Star.&nbsp;&nbsp;"
            flash[:result] << "<img src='/images/smileys/smiley-computer001.gif'/>"
          end
        else
          if @latitude and @longitude and @nation.nil?
            flash[:result] = "Sorry, your nation is not included in Franco's Star.&nbsp;&nbsp;"
            flash[:result] << "<img src='/images/smileys/smiley-computer001.gif'/>"
          else
            flash[:error] = "Data is invalid! Make sure you paste the correct, whole HTML source.&nbsp;&nbsp;"
            flash[:error] << "<img src='/images/smileys/smiley-angry009.gif'/>"
          end
        end
      end
    end
  end
  
end
