class OrderPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user&.treasurer? || user&.main_bartender? || user&.secretary?
        scope
      elsif user
        scope.orders_for(user)
      end
    end
  end

  def index?
    user
  end

  def create?
    user&.treasurer? || user&.main_bartender? || user&.secretary?
  end
end
