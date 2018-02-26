class NegativeCreditMailerJob < ApplicationJob
  queue_as :default

  def perform
    users = User.all.select { |user| user.credit.negative? }
    mail_users = users.select { |user| user.email.present? }
    mail_users.each do |user|
      CreditMailer.negative_credit_mail(user).deliver_later
    end
    no_mail_users = users.select { |user| user.email.nil? }
    User.treasurer.each do |treasurer|
      CreditMailer.treasurer_report(treasurer, no_mail_users, mail_users.size).deliver_later
    end
  end
end
