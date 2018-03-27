class UserCreditMailer < ApplicationMailer
  def insufficient_credit_mail(user)
    @user = user
    mail to: user.email, subject: 'Verzoek met betrekking op uw Zatladder saldo', content_type: 'text/plain'
  end

  def credit_delivery_report_mail(treasurer, success_count, unnotifyable_users)
    @user = treasurer
    @unnotifyable_users = unnotifyable_users
    @success_count = success_count
    mail to: treasurer.email, subject: 'Er is een saldomail verstuurd', content_type: 'text/plain'
  end
end
