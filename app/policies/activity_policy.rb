class ActivityPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user&.treasurer? || user&.renting_manager?
        scope
      elsif user&.main_bartender?
        scope.not_locked
      end
    end
  end

  def create?
    user&.treasurer? || user&.renting_manager? || user&.main_bartender?
  end

  def update?
    user&.treasurer? || user&.renting_manager? || user&.main_bartender?
  end

  def lock?
    user&.treasurer? && !record.locked?
  end

  def create_invoices?
    user&.treasurer? && record.locked?
  end

  def destroy?
    user&.treasurer? || user&.renting_manager? || user&.main_bartender?
  end

  def order_screen?
    user&.treasurer? || user&.renting_manager? || user&.main_bartender?
  end

  def summary?
    user&.treasurer? || user&.renting_manager? || user&.main_bartender?
  end

  def product_totals?
    user&.treasurer? || user&.renting_manager? || user&.main_bartender?
  end

  def orders?
    user&.treasurer? || user&.renting_manager?
  end

  def credit_mutations?
    user&.treasurer?
  end
end
