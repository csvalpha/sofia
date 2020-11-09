class InvoicePolicy < ApplicationPolicy
  def index?
    user&.treasurer?
  end

  def send_invoice?
    user&.treasurer?
  end

  def pay?
    true
  end
end
