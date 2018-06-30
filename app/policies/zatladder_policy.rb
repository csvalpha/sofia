class ZatladderPolicy < ApplicationPolicy
  def index?
    user&.treasurer?
  end
end
