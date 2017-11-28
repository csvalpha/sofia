class UserPolicy < ApplicationPolicy
  def refresh_user_list?
    user&.treasurer?
  end
end
