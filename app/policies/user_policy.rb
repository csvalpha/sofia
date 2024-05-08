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

  def json?
    user&.main_bartender? || show?
  end

  def activities?
    user&.treasurer? || record == user
  end

  def update_with_identity?
    record == user && User.active.identity.exists?(id: record)
  end
end
