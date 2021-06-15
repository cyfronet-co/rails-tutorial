# Sending emails

Generate new mailer:

```
bin/rails g mailer GrantMailer grant_created
```

  * Show generated spec
  * Modify email and test a bit

Update email preview (`test/mailers/previews/grant_mailer_preview.rb`):
```ruby
class GrantMailerPreview < ActionMailer::Preview
  def grant_created
    grant = Grant.new(title: "My grant", name: "aaa", user: User.new(email: "foo@bar.local"))
    GrantMailer.grant_created(grant)
  end
end
```

New requirement: email should be send after grant is created. Let's start with
failing test (`test/models/grant_test.rb`):
```ruby
test "sending an email after grant is created" do
  assert_difference('ActionMailer::Base.deliveries.size', 1) do
    grant = Grant.create!(
      user: users("john"), title: "My precious grant", name: "My precious!!!")
  end
end
```

Add implementation (`app/models/grant.rb`):
```ruby
after_create_commit -> { GrantMailer.grant_created(self).deliver_now }
```
