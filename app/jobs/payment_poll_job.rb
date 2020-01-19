class PaymentPollJob < ApplicationJob
  queue_as :default

  def perform # rubocop:disable Metrics/AbcSize
    Payment.not_completed.each do |payment|
      payment.update(status: payment.mollie_payment.status)
      next unless payment.mollie_payment.paid?

      CreditMutation.create(user: payment.user,
                            amount: payment.mollie_payment.amount.value,
                            description: 'iDEAL inleg', created_by: payment.user)
    end

    return unless Rails.env.production? || Rails.env.staging?

    HealthCheckJob.perform_later('payment_poll')
  end
end
