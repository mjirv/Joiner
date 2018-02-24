class ApplicationMailer < ActionMailer::Base
  default from: 'Michael Irvine <michael@getjoiner.com>'
  layout 'mailer'

  def registration_confirmation(user)
    @user = user
    mail(
      to: "#{user.name} <#{user.email}>",
      subject: "Confirm your Joiner registration"
    )
  end

  def beta_signup(user)
    @user = user
    mail(
      to: "Michael Irvine <michael@getjoiner.com>",
      subject: "New beta signup"
    )
  end
end
