require "test_helper"
require 'action_mailer/test_helper'

class GrantTest < ActiveSupport::TestCase
  test "slug is created after grant is saved into db" do
    grant = Grant.create!(
      user: users("john"), title: "My precious grant", name: "My precious!!!")

    assert_equal "my-precious", grant.slug, "Slug was wrongly generated"
  end

  test "sending an email after grant is created" do
    assert_difference('ActionMailer::Base.deliveries.size', 1) do
      grant = Grant.create!(
        user: users("john"), title: "My precious grant", name: "My precious!!!")
    end
  end
end
