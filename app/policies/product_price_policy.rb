class ProductPricePolicy < ApplicationPolicy
  def update?
    user&.treasurer?
  end

  def destroy?
    user&.treasurer?
  end

  def assign_folder?
    update?
  end

  def reorder?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
