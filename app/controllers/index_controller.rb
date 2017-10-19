class IndexController < ApplicationController
  def index
    @upcoming_activities = Activity.upcoming.limit(5)
    @current_activity = Activity.current
  end
end
