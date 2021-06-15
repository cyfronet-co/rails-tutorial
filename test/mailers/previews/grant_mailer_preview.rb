# Preview all emails at http://localhost:3000/rails/mailers/grant_mailer
class GrantMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/grant_mailer/grant_created
  def grant_created
    grant = Grant.new(title: "My grant", name: "aaa", user: User.new(email: "foo@bar.local"))
    GrantMailer.grant_created(grant)
  end
end
