class PaymentPollJob < ApplicationJob
  queue_as :default

  def perform
    Payment.not_completed.each do |payment|
      payment.update(status: payment.mollie_payment.status)
    end

    return unless Rails.env.production? || Rails.env.staging?

    HealthCheckJob.perform_later('payment_poll')
  end
end
