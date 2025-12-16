class InvoicePolicy < ApplicationPolicy
  def index?
    user&.treasurer? || user&.renting_manager?
  end

  def send_invoice?
    user&.treasurer?
  end

  def download?
    user&.treasurer?
  end

  def pay?
    show?
  end
end
