class ProductPriceFolderPolicy < ApplicationPolicy
  # Only treasurers can manage folders
  def index?
    user&.treasurer? || user&.renting_manager? || user&.main_bartender?
  end

  def show?
    index?
  end

  def create?
    user&.treasurer?
  end

  def update?
    user&.treasurer?
  end

  def destroy?
    user&.treasurer?
  end

  def reorder?
    user&.treasurer?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
