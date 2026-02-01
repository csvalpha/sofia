class PriceListPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user&.treasurer?
        scope
      elsif user&.renting_manager? || user&.main_bartender?
        scope.unarchived
      end
    end
  end

  def index?
    user&.treasurer? || user&.renting_manager? || user&.main_bartender?
  end

  def show?
    user&.treasurer? || user&.renting_manager? || user&.main_bartender?
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

  def permitted_attributes
    %i[name]
  end
end
