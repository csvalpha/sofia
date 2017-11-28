class CreditMutationPolicy < ApplicationPolicy
  def index?
    user&.treasurer?
  end

  def create?
    user&.treasurer? || user&.main_bartender?
  end
end
