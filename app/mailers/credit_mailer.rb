class CreditMailer < ApplicationMailer
  def negative_credit_mail(user)
    @user = user
    mail to: user.email, subject: 'Verzoek met betrekking op uw Zatladder saldo', content_type: 'text/plain'
  end

  def treasurer_report(treasurer, mail_unknown_users, send_to_count)
    @treasurer = treasurer
    @mail_unknown_user = mail_unknown_users
    @send_to_count = send_to_count
    mail to: treasurer.email, subject: 'Er is een saldomail verstuurd', content_type: 'text/plain'
  end
end
