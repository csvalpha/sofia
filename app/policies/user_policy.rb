class UserPolicy < ApplicationPolicy
  def refresh_user_list?
    user&.treasurer?
  end

  def search?
    index?
  end
end
