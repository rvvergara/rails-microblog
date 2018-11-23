class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy] 
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def index 
  #  @users = User.all
  @users = User.paginate(page: params[:page]) 
  end

  def show
    begin
      @user = User.find(params[:id])
    rescue => e
      flash[:danger] = "Cannot find user"
      if logged_in?
        redirect_to users_path
      else
        redirect_to root_path
      end
    end
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in(@user)
      flash[:success] = "Welcome to MicroBlog, #{@user.name}!!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Your profile is updated!"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    @user = User.find_by(id:params[:id])
    if !@user.nil?
      @user.delete
      flash[:warning] = "User deleted"
      redirect_to users_path
    else
      store_location
      flash[:danger] = "User does not exist or already deleted"
      redirect_to users_path
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # Before filters

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "You must be logged in to do that!"
        redirect_to login_url
      end
    end

    # Confirms the correct user
    def correct_user
      @target_user = User.find(params[:id])
      unless current_user?(@target_user)
        flash[:danger] = "Don't do that to someone else's profile dude!"
        redirect_to root_path
      end
    end
  
  def admin_user
    unless current_user.admin?
      redirect_to root_path
    end
  end
    
end
