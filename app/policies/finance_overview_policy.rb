class FinanceOverviewPolicy < ApplicationPolicy
  def index?
    user&.treasurer?
  end
end
