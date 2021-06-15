require "test_helper"

class GrantTest < ActiveSupport::TestCase
  test "slug is created after grant is saved into db" do
    grant = Grant.create!(
      user: users("john"), title: "My precious grant", name: "My precious!!!")

    assert_equal "my-precious", grant.slug, "Slug was wrongly generated"
  end
end
