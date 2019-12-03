class ActivityPolicy < ApplicationPolicy
  def create?
    user&.treasurer? || user&.main_bartender?
  end

  def lock?
    user&.treasurer? && !record.locked?
  end

  def activity_report?
    user&.treasurer?
  end

  def order_screen?
    user&.treasurer? || user&.main_bartender?
  end
end
