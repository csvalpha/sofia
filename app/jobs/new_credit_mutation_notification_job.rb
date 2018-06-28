class NewCreditMutationNotificationJob < ApplicationJob
  queue_as :default

  def perform(mutation)
    return if mutation.user.email.blank?
    UserCreditMailer.new_credit_mutation_mail(mutation).deliver_later
  end
end
