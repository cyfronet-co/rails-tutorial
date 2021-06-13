class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @now = Time.now
  end
end
