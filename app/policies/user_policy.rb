class UserPolicy < ApplicationPolicy
  def refresh_user_list?
    user&.treasurer?
  end

  def show?
    user&.treasurer? || record == user
  end
end
