class SessionsController < ApplicationController
  def create
    user = User.find_or_initialize_by(uid: auth.uid).tap do |u|
      u.name = auth.info.name
      u.email = auth.info.email
      u.save!
    end
    session[:user_id] = user.id

    redirect_to root_path, info: "Authenticated"
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Signed out!"
  end

  private
    def auth
      request.env['omniauth.auth']
    end
end
