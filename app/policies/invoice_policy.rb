class InvoicePolicy < ApplicationPolicy
  def index?
    user&.treasurer? || user&.secretary?
  end

  def send_invoice?
    user&.treasurer?
  end

  def pay?
    show?
  end
end
