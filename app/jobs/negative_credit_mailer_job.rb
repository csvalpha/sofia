class NegativeCreditMailerJob < ApplicationJob
  queue_as :default

  def perform
    users = users_with_negative_credit
    send_credit_mail(users)
    send_report(users)
  end

  private

  def users_with_negative_credit
    User.all.select { |user| user.credit.negative? }
  end

  def send_credit_mail(negative_users)
    mail_users = negative_users.select { |user| user.email.present? }
    mail_users.each do |user|
      CreditMailer.negative_credit_mail(user).deliver_later
    end
  end

  def send_report(negative_users)
    no_mail_users = negative_users.select { |user| user.email.nil? }
    User.treasurer.each do |treasurer|
      CreditMailer.treasurer_report(treasurer, no_mail_users, mail_users.size).deliver_later
    end
  end
end
