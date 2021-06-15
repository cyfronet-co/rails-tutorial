class GrantMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.grant_mailer.grant_created.subject
  #
  def grant_created(grant)
    @grant_title = grant.title

    mail to: grant.user.email
  end
end
