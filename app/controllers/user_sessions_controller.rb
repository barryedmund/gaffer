class UserSessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create

  def new
  end

  def index
  end

  def create
  	user = User.find_by(email: params[:email].downcase)
  	if user && user.authenticate(params[:password])
  		session[:user_id] = user.id
  		flash[:success] = "Welcome back #{user.first_name}!"
  		redirect_to root_path
  	else
  		flash[:error] = "Erp! That email / password combo doesn't exist. Try again."
  		render action: 'new'
  	end
  end

  def destroy
    session[:user_id] = nil
    reset_session
    redirect_to root_path, notice: "Please log in or create an account before continuing."
  end
end
