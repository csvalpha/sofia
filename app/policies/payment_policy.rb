class PaymentPolicy < ApplicationPolicy
  def index?
    user.treasurer?
  end

  def create?
    user
  end

  def add?
    user
  end

  def invoice_callback?
    record && !record.completed
  end
end
