# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter { |c| Authorization.current_user = c.current_user } 
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  helper_method :current_user  
  
  def permission_denied
    flash[:error] = "Sorry, you not allowed to access that page."
    if current_user
      redirect_to home_users_path
    else
      redirect_to login_path
    end
  end 
   
  def current_user_session  
    return @current_user_session if defined?(@current_user_session)  
    @current_user_session = UserSession.find  
  end  
    
  def current_user  
    @current_user = current_user_session && current_user_session.record  
  end
  
end
