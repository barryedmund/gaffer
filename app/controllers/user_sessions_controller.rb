class UserSessionsController < ApplicationController
  def new
  end

  def create
  	user = User.find_by(email: params[:email])
  	if user && user.authenticate(params[:password])
  		session[:user_id] = user.id
  		flash[:success] = "Welcome back #{user.first_name}!"
  		redirect_to users_url
  	else
  		flash[:error] = "There was a problem logging in. Please check your email and password."
  		render action: 'new'
  	end
  end
end
