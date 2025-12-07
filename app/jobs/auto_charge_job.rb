class AutoChargeJob < ApplicationJob
  queue_as :default

  def perform
    # Find all users with auto_charge_enabled and valid mandates with negative credit
    User.where(auto_charge_enabled: true).each do |user|
      next unless user.mandate_valid?
      next unless user.credit.negative?

      begin
        charge_user(user)
      rescue StandardError => e
        Rails.logger.error("AutoChargeJob failed for user #{user.id}: #{e.message}")
        # Continue with next user
      end
    end

    return unless Rails.env.production? || Rails.env.staging? || Rails.env.luxproduction? || Rails.env.euros?

    HealthCheckJob.perform_later('auto_charge')
  end

  private

  def charge_user(user) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    # Calculate amount needed to bring balance back to 0 or add buffer
    amount_needed = (user.credit.abs + 1.00).round(2) # Add 1 euro buffer

    # Cap at reasonable amount to prevent accidental large charges
    amount_needed = 100.00 if amount_needed > 100.00

    return if amount_needed < 0.01

    # Create payment with mandate using Mollie API
    mollie_customer = Mollie::Customer.get(user.mollie_customer_id)
    mollie_mandate = mollie_customer.mandates.get(user.mollie_mandate_id)

    return unless mollie_mandate.status == 'valid'

    # Create a recurring payment (charge)
    mollie_payment = mollie_customer.payments.create(
      amount: { value: format('%.2f', amount_needed), currency: 'EUR' },
      description: 'Automatische opwaardering (onderschrijving)',
      mandateId: user.mollie_mandate_id,
      sequenceType: 'recurring',
      redirectUrl: "http://#{Rails.application.config.x.sofia_host}/users/#{user.id}"
    )

    # Create payment record in database
    payment = Payment.create(
      user:,
      amount: amount_needed,
      mollie_id: mollie_payment.id,
      status: mollie_payment.status
    )

    Rails.logger.info("AutoChargeJob created payment #{payment.id} for user #{user.id} with amount #{amount_needed}")

    # If payment is already paid (for recurring), process it immediately
    if mollie_payment.paid?
      payment.update(status: 'paid')
    end
  rescue Mollie::ResponseError => e
    Rails.logger.error("Mollie API error in AutoChargeJob for user #{user.id}: #{e.message}")
    raise
  end
end
