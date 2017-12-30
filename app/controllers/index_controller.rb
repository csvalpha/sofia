class IndexController < ApplicationController
  after_action :verify_authorized, except: :index

  def index
    @upcoming_activities = Activity.upcoming.limit(5)
    @current_activities = Activity.current
  end

  def current_user
    @current_user ||= super && User.includes(roles_users: :role).find(@current_user.id)
  end
end
