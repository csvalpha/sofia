class UserPolicy < ApplicationPolicy
  def index?
    user&.treasurer?
  end

  def refresh_user_list?
    user&.treasurer?
  end

  def search?
    index?
  end

  def show?
    user&.treasurer? || record == user
  end
end
