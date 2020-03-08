class InvoicePolicy < ApplicationPolicy
  def index?
    user&.treasurer?
  end
end
