class PriceListPolicy < ApplicationPolicy
  def index?
    user&.treasurer? || user&.main_bartender?
  end

  def show?
    user&.treasurer? || user&.main_bartender?
  end

  def create?
    user&.treasurer?
  end

  def update?
    create?
  end

  def archive?
    create?
  end

  def unarchive?
    create?
  end

  def search?
    index?
  end
end
