class ActivityPolicy < ApplicationPolicy
  def create?
    user&.treasurer? || user&.main_bartender?
  end

  def activity_report?
    user&.treasurer?
  end

  def send_credit_mail?
    user&.treasurer?
  end
end
