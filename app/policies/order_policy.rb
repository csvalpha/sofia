class OrderPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user&.treasurer? || user&.main_bartender?
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
    user&.treasurer? || user&.main_bartender?
  end
end
