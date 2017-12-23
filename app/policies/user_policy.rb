class UserPolicy < ApplicationPolicy
  def refresh_user_list?
    user&.treasurer?
  end

  def show?
    record == user
  end
end
