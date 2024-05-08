class UserMailer < ApplicationMailer
  def account_creation_email(user)
    @user = user
    @activate_account_url = Identity.activate_account_url(@user.id, @user.activation_token)
    @new_activation_link_url = Identity.new_activation_link_url(@user.id)
    @header_text = "Welkom op #{Rails.application.config.x.site_name}!"
    @call_to_action = { text: 'Klik hier om uw account te activeren!', url: @activate_account_url }
    mail to: user.email, subject: "Accountactivatie voor het streepsysteem van uw vereniging"
  end

  def new_activation_link_email(user)
    @user = user
    @activate_account_url = Identity.activate_account_url(@user.id, @user.activation_token)
    @new_activation_link_url = Identity.new_activation_link_url(@user.id)
    @header_text = "Welkom op #{Rails.application.config.x.site_name}!"
    @call_to_action = { text: 'Klik hier om uw account te activeren!', url: @activate_account_url }
    mail to: user.email, subject: "Accountactivatie voor het streepsysteem van uw vereniging"
  end

  def forgot_password_email(user)
    @user = user
    @username = user.identity.username
    @reset_password_url = user.identity.reset_password_url(@user.activation_token)
    @forgot_password_url = Identity.forgot_password_url
    @call_to_action = { text: 'Wachtwoord herstellen!', url: @reset_password_url }
    mail to: user.email, subject: "Wachtwoordherstel voor het streepsysteem van uw vereniging"
  end
end
