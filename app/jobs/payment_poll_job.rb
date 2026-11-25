class PaymentPollJob < ApplicationJob
  queue_as :default

  def perform
    Payment.not_completed.each do |payment|
      if payment.mollie_id.nil?
        # Mollie::Payment.create can fail to return an id (e.g. the API call errored after
        # the record was created), leaving the payment stuck in `not_completed` forever
        payment.update(status: 'failed') if payment.created_at < 15.minutes.ago
        next
      end

      payment.update(status: payment.mollie_payment.status)
    rescue ActiveRecord::StaleObjectError
      # If the payment has not changed to paid with this concurrent update,
      # it will be checked again the next time this poll job runs
    end

    return if Rails.env.local?

    HealthCheckJob.perform_later('payment_poll')
  end
end
