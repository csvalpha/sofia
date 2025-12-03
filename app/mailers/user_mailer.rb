class UserMailer < ApplicationMailer
  def account_creation_email(user)
    send_activation_email(user)
  end

  def new_activation_link_email(user)
    send_activation_email(user)
  end

  def forgot_password_email(user)
    @user = user
    raise ArgumentError, 'User must have a SofiaAccount' unless user.sofia_account

    @username = user.sofia_account.username
    @reset_password_url = user.sofia_account.reset_password_url(@user.activation_token)
    @forgot_password_url = SofiaAccount.forgot_password_url
    @call_to_action = { text: 'Wachtwoord herstellen!', url: @reset_password_url }
    mail to: user.email, subject: 'Wachtwoordherstel voor het streepsysteem van uw vereniging'
  end

  private

  def send_activation_email(user)
    @user = user
    @activate_account_url = SofiaAccount.activate_account_url(@user.id, @user.activation_token)
    @new_activation_link_url = SofiaAccount.new_activation_link_url(@user.id)
    @header_text = "Welkom op #{Rails.application.config.x.site_name}!"
    @call_to_action = { text: 'Klik hier om uw account te activeren!', url: @activate_account_url }
    mail to: user.email, subject: 'Accountactivatie voor het streepsysteem van uw vereniging'
  end
end
