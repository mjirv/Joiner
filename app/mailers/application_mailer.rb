class ApplicationMailer < ActionMailer::Base
  default from: 'michael@getjoiner.com'
  layout 'mailer'

  def registration_confirmation(user)
    @user = user
    mail(
      to: "#{user.name} <#{user.email}>",
      subject: "Confirm your Joiner registration"
    )
  end
end
