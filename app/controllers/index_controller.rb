class IndexController < ApplicationController
  after_action :verify_authorized, except: :index

  def index
    @upcoming_activities = Activity.upcoming.limit(5)
    @current_activities = Activity.current
  end
end
