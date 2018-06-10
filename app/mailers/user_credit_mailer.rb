class UserCreditMailer < ApplicationMailer
  def insufficient_credit_mail(user)
    @user = user
    @title = 'Notificatie over je saldo'
    @cab_link = @user.profile_url
    mail to: user.email, subject: 'Verzoek met betrekking tot uw Zatladder saldo'
  end

  def credit_delivery_report_mail(treasurer, success_count, unnotifyable_users)
    @user = treasurer
    @unnotifyable_users = unnotifyable_users
    @success_count = success_count
    @title = 'Notificatie over de saldomail'

    subject = "Er is #{@success_count.positive? ? 'een' : 'geen'} saldomail verstuurd"

    mail to: treasurer.email, subject: subject
  end

  def new_credit_mutation_mail(credit_mutation)
    @user = credit_mutation.user
    @title = 'Bedankt voor het inleggen'
    @credit_mutation_amount = credit_mutation.amount
    @credit_mutation_description = credit_mutation.description

    subject = 'Je betaling aan flux is verwerkt'

    mail to: credit_mutation.user.email, subject: subject
  end
end
