class UserMailer < ApplicationMailer
  default from: ENV['GMAIL_USERNAME']

  def verification_email(user)
    @user = user
    mail(to: @user.email, subject: "Código de Verificação")
  end
end
