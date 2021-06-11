class WelcomeController < ApplicationController
  def index
    @now = Time.now
  end
end
