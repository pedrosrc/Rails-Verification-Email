class UserMailer < ApplicationMailer
  default from: Rails.application.credentials.gmail_username

  def verification_email(user)
    @user = user
    mail(to: @user.email, subject: "Verification Code")
  end
end
