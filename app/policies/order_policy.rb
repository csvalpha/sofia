class OrderPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      if user&.treasurer? || user&.renting_manager? || user&.main_bartender?
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
    user&.treasurer? || user&.renting_manager? || user&.main_bartender?
  end
end
