class PriceListPolicy < ApplicationPolicy
  def index?
    user&.treasurer?
  end

  def show?
    user&.treasurer? || user&.main_bartender?
  end
end
