class NegativeCreditMailerJob < ApplicationJob
  queue_as :default

  def perform
    send_credit_mail
    send_deliver_report
  end

  private

  def users_with_negative_credit
    User.all.select { |user| user.credit.negative? }
  end

  def negative_users_with_mail
    users_with_negative_credit.select { |user| user.email.present? }
  end

  def send_credit_mail
    negative_users_with_mail.each do |user|
      CreditMailer.negative_credit_mail(user).deliver_later
    end
  end

  def send_deliver_report
    no_mail_users = users_with_negative_credit.select { |user| user.email.nil? }
    User.treasurer.each do |treasurer|
      CreditMailer.credit_delivery_report_mail(treasurer, no_mail_users, negative_users_with_mail.size).deliver_later
    end
  end
end
