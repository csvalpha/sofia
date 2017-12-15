class ProductPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    user&.treasurer?
  end

  def update?
    create?
  end
end
