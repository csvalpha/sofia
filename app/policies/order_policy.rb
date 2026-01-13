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

  def permitted_attributes
    %i[user_id paid_with_cash paid_with_pin activity_id]
  end

  def permitted_attributes_for_create
    permitted_attributes + [order_rows_attributes: %i[id product_id product_count]]
  end

  def permitted_attributes_for_update
    [:id, order_rows_attributes: %i[id product_count]]
  end
end
