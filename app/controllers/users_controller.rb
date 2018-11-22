class UsersController < ApplicationController
  before_action :logged_in_user, :correct_user, only: [:edit, :update] 

  def index 
   @users = User.all 
  end

  def show
    begin
      @user = User.find(params[:id])
    rescue => e
      flash[:danger] = "Cannot find user"
      redirect_to users_path
    end
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
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

    def current_user?(user)
      current_user == user
    end

    # Confirms the correct user
    def correct_user
      @target_user = User.find(params[:id])
      unless current_user?(@target_user)
        flash[:danger] = "Don't do that to someone else's profile dude!"
        redirect_to root_path
      end
    end
end
