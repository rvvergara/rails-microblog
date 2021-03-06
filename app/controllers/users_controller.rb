class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :following, :followers] 
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def index 
  @users = User.where(activated:true).paginate(page: params[:page])
  end

  def show
    @user = User.find_by(id:params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    if @user.nil?
      flash[:danger] = "Cannot find user"
      logged_in? ? redirect_to(users_path) : redirect_to(root_path)
    else
      if !@user.activated?
        flash[:warning] = "Selected user hasn't activated his/her account"
        redirect_to users_path
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
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account"
      redirect_to root_path
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

  def following
    @title = "Following"
    @user = User.find_by(id:params[:id])
    @users = @user.following.paginate(page: params[:page])
    render "show_follow"
  end

  def followers
    @title = "Followers"
    @user = User.find_by(id:params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render "show_follow"
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # Before filters
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
