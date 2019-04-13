class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  add_flash_types :success
  before_action :set_last_seen_at, if: proc { logged_in? }

  private
  def logged_in?
    current_user
  end
  helper_method :logged_in?

  def current_user
  	@current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def require_user
  	if current_user
  		true
  	else
      redirect_to root_path, notice: "Please log in or create an account before continuing."
  	end
  end

  def set_last_seen_at
    current_user.update_attribute(:last_seen_at, Time.now)
  end
end
