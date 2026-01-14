class CreditMutationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user&.treasurer?
        scope
      elsif user&.main_bartender?
        scope.linked_to_activity
      end
    end
  end

  def index?
    user&.treasurer? || user&.main_bartender?
  end

  def create?
    user&.treasurer? || (user&.main_bartender? && record.activity.present?)
  end

  def permitted_attributes
    %i[description amount user_id activity_id]
  end
end
