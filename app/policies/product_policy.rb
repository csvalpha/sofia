class ProductPolicy < ApplicationPolicy
  def create?
    user&.treasurer?
  end

  def update?
    create?
  end
end
