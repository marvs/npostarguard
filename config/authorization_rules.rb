authorization do
  role :guest do
    has_permission_on :user_sessions, :to => [:new, :create, :destroy]
    has_permission_on :users, :to => [:home, :new, :create]
    has_permission_on :starguards, :to => [:parsed_url_method]
    has_permission_on :nations, :to => :show_coords
  end
  
  role :default_user do
    has_permission_on :user_sessions, :to => [:new, :create, :destroy]
    has_permission_on :users, :to => [:show, :home]
    has_permission_on :users, :to => :owner_access do
      if_attribute :id => is {user.id}
    end
    has_permission_on :starguards, :to => [:parsed_url_method]
    has_permission_on :nations, :to => :show_coords
  end
  
  role :admin do
    has_permission_on :user_sessions, :to => [:new, :create, :destroy]
    
    # Home Page
    has_permission_on :users, :to => [:home]
    
    # User Management
    has_permission_on :roles, :to => [:manage]
    has_permission_on :users, :to => [:manage]
    
    # Star Guard
    has_permission_on :starguards, :to => [:manage, :scan_alliance_map, :preview_master_list, :forum_code, :star_design, :star_points, :nation_message, :nation_thanks_message, :parsed_url_method, :show_by_ranking]
    has_permission_on :nations, :to => [:manage, :show_coords]
    has_permission_on :master_coordinates, :to => [:manage]
    has_permission_on :coordinate_groups, :to => :manage
  end
  
  role :star_guard_astronomer do
    has_permission_on :user_sessions, :to => [:new, :create, :destroy]
    
    # Home Page
    has_permission_on :users, :to => [:home, :index, :show, :update_designation]
    
    # Profile
    has_permission_on :users, :to => :owner_access do
      if_attribute :id => is {user.id}
    end
    
    # Star Guard
    has_permission_on :starguards, :to => [:manage_no_update, :scan_alliance_map, :preview_master_list, :forum_code, :star_design, :star_points, :nation_message, :nation_thanks_message, :parsed_url_method, :show_by_ranking]
    has_permission_on :nations, :to => [:manage_no_destroy, :show_coords]
    has_permission_on :master_coordinates, :to => [:index, :edit, :update]
  end
  
  role :star_guard_observer do
    has_permission_on :user_sessions, :to => [:new, :create, :destroy]
    
    # Home Page
    has_permission_on :users, :to => [:home]
    
    # Profile
    has_permission_on :users, :to => :owner_access do
      if_attribute :id => is {user.id}
    end
    
    # Star Guard
    has_permission_on :starguards, :to => [:index, :show, :scan_alliance_map, :preview_master_list, :forum_code, :star_design, :star_points, :nation_message, :nation_thanks_message, :parsed_url_method, :show_by_ranking]
    has_permission_on :nations, :to => [:manage_no_destroy, :show_coords]
    #has_permission_on :master_coordinates, :to => [:index, :edit, :update]
  end
  
end

privileges do
  privilege :owner_access do
    includes :show, :edit, :update
  end
  privilege :manage do
    includes :index, :show, :new, :edit, :create, :update, :destroy
  end
  privilege :manage_no_destroy do
    includes :index, :show, :new, :edit, :create, :update
  end
  privilege :manage_no_update do
    includes :index, :show, :create, :destroy
  end
  privilege :manage_no_update_no_destroy do
    includes :index, :show, :create
  end
end
