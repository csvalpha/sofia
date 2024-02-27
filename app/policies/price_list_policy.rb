class PriceListPolicy < ApplicationPolicy
  def index?
    user&.treasurer? || user&.main_bartender? || user&.renting_manager?
  end

  def show?
    user&.treasurer? || user&.main_bartender? || user&.renting_manager?
  end

  def create?
    user&.treasurer?
  end

  def update?
    create?
  end

  def search?
    index?
  end
end
