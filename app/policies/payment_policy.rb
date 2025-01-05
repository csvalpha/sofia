class PaymentPolicy < ApplicationPolicy
  def index?
    mollie_enabled? && user&.treasurer?
  end

  def create?
    mollie_enabled? && user
  end

  def add?
    mollie_enabled? && user
  end

  def invoice_callback?
    mollie_enabled? && record && !record.completed?
  end

  def mollie_enabled?
    Rails.application.config.x.mollie_api_key.present?
  end
end
