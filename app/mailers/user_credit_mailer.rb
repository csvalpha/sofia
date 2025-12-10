class UserCreditMailer < ApplicationMailer
  def insufficient_credit_mail(user)
    @user = user
    @title = 'Notificatie over je saldo'
    @cab_link = url_for(controller: 'payments', action: 'add', resulting_credit: Rails.application.config.x.min_payment_amount)
    @cab_text = "Saldo opwaarderen naar #{number_to_currency(Rails.application.config.x.min_payment_amount, unit: '€')}"
    mail to: user.email, subject: 'Verzoek met betrekking tot uw Zatladder saldo'
  end

  def credit_delivery_report_mail(treasurer, success_count, unnotifyable_users)
    @user = treasurer
    @unnotifyable_users = unnotifyable_users
    @success_count = success_count
    @title = 'Notificatie over de saldomail'

    subject = "Er is #{@success_count.positive? ? 'een' : 'geen'} saldomail verstuurd"

    mail to: treasurer.email, subject:
  end

  def new_credit_mutation_mail(credit_mutation)
    @user = credit_mutation.user
    @title = 'Je saldo is bijgewerkt'
    @credit_mutation_amount = credit_mutation.amount
    @credit_mutation_description = credit_mutation.description
    @credit_mutation_time = credit_mutation.created_at

    mail to: credit_mutation.user.email, subject: 'Je saldo is bijgewerkt'
  end
end
