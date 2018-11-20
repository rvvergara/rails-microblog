class UsersController < ApplicationController
  
  def index
    
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
end
