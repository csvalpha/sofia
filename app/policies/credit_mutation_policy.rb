class CreditMutationPolicy < ApplicationPolicy
  def create?
    user&.treasurer? || user&.main_bartender?
  end
end
