class IndexController < ApplicationController
  after_action :verify_authorized, except: :index

  def index
    redirect_to current_user if current_user && current_user.roles_users.empty?
    @upcoming_activities = Activity.upcoming.limit(5)
    @current_activities = Activity.current
  end
end
