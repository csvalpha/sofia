class CreditMutationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user&.treasurer? || user&.secretary?
        scope
      elsif user&.main_bartender?
        scope.linked_to_visible_activity
      end
    end
  end

  def create?
    user&.treasurer? || (
      (user&.main_bartender? || user&.secretary?) && record.activity.present?
    )
  end
end
