class PaymentPollJob < ApplicationJob
  queue_as :default

  def perform
    Payment.not_completed.each do |payment|
      begin
        payment.update(status: payment.mollie_payment.status)
      rescue ActiveRecord::StaleObjectError => e
        # If the payment has not changed to paid with this concurrent update,
        # it will be checked again the next time this poll job runs
      end
    end

    return unless Rails.env.production? || Rails.env.staging?

    HealthCheckJob.perform_later('payment_poll')
  end
end
