class InvoicePolicy < ApplicationPolicy
  def index?
    user&.treasurer? || user&.renting_manager?
  end

  def send_invoice?
    user&.treasurer?
  end

  def pay?
    show?
  end

  def permitted_attributes
    [
      :user_id, :activity_id, :name_override, :email_override, :rows,
      { rows_attributes: %i[name amount price] }
    ]
  end
end
