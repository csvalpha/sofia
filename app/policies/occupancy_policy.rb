class OccupancyPolicy < ApplicationPolicy
  def index?
    user.present? && BarOccupancy.enabled?
  end
end
