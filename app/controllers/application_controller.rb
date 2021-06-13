class ApplicationController < ActionController::Base
  before_action :authentiate_user!

  helper_method :current_user

  private
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end

    def authenticate_user!
      redirect_to root_path, alert: "Login is required" unless current_user
    end
end
