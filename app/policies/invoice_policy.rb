class InvoicePolicy < ApplicationPolicy
  def index?
    user&.treasurer?
  end

  def send?
    user&.treasurer?
  end
end
