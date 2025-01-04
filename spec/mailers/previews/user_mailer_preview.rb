# Preview all emails at http://localhost:5000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def account_creation_mail
    user = User.new(id: 999_999, provider: 'sofia_account', activation_token: 'mockup_activation_token')
    UserMailer.account_creation_email(user)
  end

  def forgot_password_mail
    user = User.new(id: 999_999, provider: 'sofia_account', activation_token: 'mockup_activation_token')
    sofia_account = SofiaAccount.new(id: 888_888, user: user, username: 'mockup_username')
    UserMailer.forgot_password_email(user)
  end

  def new_activation_link_mail
    user = User.new(id: 999_999, provider: 'sofia_account', activation_token: 'mockup_activation_token')
    UserMailer.new_activation_link_email(user)
  end
end
