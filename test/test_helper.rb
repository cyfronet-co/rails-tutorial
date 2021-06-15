ENV['RAILS_ENV'] ||= 'test'
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  OmniAuth.config.test_mode = true

  # Add more helper methods to be used by all tests here...
  def sign_in_as(name)
    stub_oauth_for(name)
    get "/auth/plgrid/callback"
  end

  def stub_oauth_for(name)
    user = users(name)
    OmniAuth.config.add_mock(
      "plgrid",
      uid: user.uid,
      info: {
        name: user.name,
        email: user.email
      }
    )
  end
end
