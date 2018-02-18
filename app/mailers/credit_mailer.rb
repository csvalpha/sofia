class CreditMailer < ApplicationMailer
  def negative_credit_mail(user)
    @user = user
    mail to: 'test@jan.nl', subject: 'U heeft een negatief Fluxsaldo', content_type: 'text/plain'
  end
end
