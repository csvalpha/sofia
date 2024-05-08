class IdentityPolicy < ApplicationPolicy
  def update?
    record.user == user && User.exists?(id: record.user)
  end

  def update_with_identity?
    update?
  end

  def update_password?
    update?
  end

  def enable_otp?
    update?
  end

  def disable_otp?
    update?
  end
end
