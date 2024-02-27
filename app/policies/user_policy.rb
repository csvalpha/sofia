class UserPolicy < ApplicationPolicy
  def index?
    user&.treasurer? || user&.main_bartender? || user&.renting_manager?
  end

  def refresh_user_list?
    user&.treasurer?
  end

  def search?
    index?
  end

  def show?
    user&.treasurer? || (user&.renting_manager? && User.manual.exists?(id: record)) || record == user
  end

  def json?
    user&.main_bartender? || show?
  end

  def activities?
    show?
  end
end
