class NegativeCreditMailer < ApplicationJob
  queue_as :default

  def perform
    users = User.all.select { |user| user.credit.negative? }
    users.each do |user|
      CreditMailer.negative_credit_mail(user).deliver_later
    end
  end
end
