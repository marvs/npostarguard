# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Default menu/sub-menu
  def default_main_and_sub_menu
    @main_menu_id = ""
    @sub_menu_id = ""
  end
  
  # Determine if it is currently selected menu
  def get_main_menu_id(current_page_id)
    list_id = ""
    if in_main_menu?(current_page_id)
      list_id = "current-page"
    end
    return list_id
  end
  
  # Determine if it is currently selected page
  def get_sub_menu_id(current_page_id)
    list_id = ""
    if @sub_menu_id == current_page_id
      list_id = "current-sub-page"
    end
    return list_id
  end

  def in_main_menu?(current_page_id)
    @main_menu_id == current_page_id
  end
  
end
