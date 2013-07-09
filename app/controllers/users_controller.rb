class UsersController < ApplicationController
  filter_access_to :show, :edit, :update, :attribute_check => true
  filter_access_to :all
  
  before_filter :set_main_menu_id
  
  def set_main_menu_id
    @main_menu_id = "users"
  end

  def home
    @main_menu_id = "home"
  end
  
  def index
    @search = User.ascend_by_username.search(params[:search])
    @users = @search.paginate(:per_page => AppConfig.pagination_limit, :page => params[:page])
    @roles = Role.all
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
    @roles = Role.find_all_by_name("Default User")
  end
  
  def create
    @user = User.new(params[:user])
    
    @roles = Role.find_all_by_name("Default User")
    if @user.save
      flash[:notice] = "Registration successful."
      redirect_to @user
    else
      render :action => 'new'
    end
  end
  
  def edit
    @user = User.find(params[:id])
    @roles = Role.all
    unless current_user.roles.include?(Role.find_by_id(1))
      @roles.delete(Role.find_by_id(1))
    end
  end
  
  def update
    @user = User.find(params[:id])
    @roles = Role.all
    unless current_user.roles.include?(Role.find_by_id(1))
      @roles.delete(Role.find_by_id(1))
    end
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated user."
      redirect_to @user
    else
      render :action => 'edit'
    end
  end
  
  def update_designation
  
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = "Successfully destroyed user."
    redirect_to users_url
  end
end
