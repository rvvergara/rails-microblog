class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit,:update]
  before_action :check_expiration, only: [:edit,:update] 
  before_action :password_presence, only: [:update]
  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions."
      redirect_to root_path
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      @user.update_attribute(:reset_digest,nil)
      flash[:success] = "Password changed"
      redirect_to @user   
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password,:password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
    if @user.nil?
      flash[:danger] = "Wrong link"
    end
  end

  def valid_user
    redirect_to root_path unless @user && @user.activated? && @user.authenticated?(:reset,params[:id])
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired"
      redirect_to new_password_reset_path
    end
  end

  def password_presence
    if params[:user][:password].empty?
      @user.errors.add(:password, "cannot be empty")
      render 'edit'
    end
  end

end
