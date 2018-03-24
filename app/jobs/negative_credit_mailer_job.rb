class NegativeCreditMailerJob < ApplicationJob
  queue_as :default

  def perform
    users = users_with_negative_credit
    success_count = send_credit_mail(users)
    send_report(users, success_count)
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
    mail_users.size
  end

  def send_report(negative_users, success_count)
    no_mail_users = negative_users.select { |user| user.email.nil? }
    User.treasurer.each do |treasurer|
      CreditMailer.credit_delivery_report_mail(treasurer, no_mail_users, success_count).deliver_later
    end
  end
end
