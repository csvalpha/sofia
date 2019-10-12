# Preview all emails at http://localhost:5000/rails/mailers/user_credit_mailer
class UserCreditMailerPreview < ActionMailer::Preview
  def insufficient_credit_mail
    user = FactoryBot.create(:user)
    UserCreditMailer.insufficient_credit_mail(user)
  end

  def credit_delivery_report_mail
    treasurer = FactoryBot.create(:user, :treasurer)
    unnotifyable_users = FactoryBot.create_list(:user, 2).map(&:name)
    success_count = 2

    UserCreditMailer.credit_delivery_report_mail(treasurer, success_count, unnotifyable_users)
  end

  def new_credit_mutation_mail
    credit_mutation = FactoryBot.create(:credit_mutation)
    UserCreditMailer.new_credit_mutation_mail(credit_mutation)
  end
end
