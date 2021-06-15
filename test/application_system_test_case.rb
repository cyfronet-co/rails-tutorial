require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  # Add more helper methods to be used by all tests here...
  def sign_in_as(name)
    stub_oauth_for(name)
    visit "/auth/plgrid/callback"
  end
end
