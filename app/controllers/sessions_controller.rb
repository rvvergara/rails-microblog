class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
      log_in(user)
      params[:session][:remember_me] == "1" ? remember(user) : forget(user)
      flash[:success] = "Welcome to Microblog, #{user.name}!"
      redirect_back_or(user)
      else
        message = "Account not activated."
        message += " Check email for activation link."
        flash[:warning] = message
        redirect_to root_path
      end
    else
      flash.now[:danger] = "Invalid email/password combination"
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    flash[:warning] = "You have been logged out"
    redirect_to root_path
  end
end
