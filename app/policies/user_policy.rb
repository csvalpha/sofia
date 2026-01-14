class UserPolicy < ApplicationPolicy
  def index?
    user&.treasurer? || user&.renting_manager? || user&.main_bartender?
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

  def update_with_sofia_account?
    record == user
  end

  def permitted_attributes
    %i[name email provider sub_provider]
  end

  def permitted_attributes_for_update
    %i[name email deactivated]
  end

  def permitted_attributes_for_update_with_sofia_account
    base = %i[email sub_provider]
    base += %i[name deactivated] if user&.treasurer?
    base + [{ sofia_account_attributes: %i[id username] }]
  end
end
