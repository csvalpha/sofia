class ProductPricePolicy < ApplicationPolicy
  def destroy?
    user&.treasurer?
  end
end
