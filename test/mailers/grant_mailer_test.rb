require "test_helper"

class GrantMailerTest < ActionMailer::TestCase
  test "grant_created" do
    grant = grants("one")
    mail = GrantMailer.grant_created(grant)

    assert_equal "Grant created", mail.subject
    assert_equal [grant.user.email], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "#{grant.title} was created", mail.body.encoded
  end

end
