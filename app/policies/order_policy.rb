class OrderPolicy < ApplicationPolicy
  def create?
    user&.treasurer? || user&.main_bartender?
  end

  def destroy?
    user&.treasurer? && !record.activity.locked?
  end
end
