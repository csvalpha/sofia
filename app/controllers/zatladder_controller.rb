class ZatladderController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    authorize :zatladder

    @from_date = Order.first&.created_at || Time.zone.now
    @to_date = Order.last&.created_at || Time.zone.now
    @zatladder = zatladder_spendings
  end

  private

  def zatladder_spendings
    @users_spendings = User.calculate_spendings
    zatladder = User.select(:id, :name).map do |user|
      {
        id: user.id,
        name: user.name,
        spendings: @users_spendings.fetch(user.id, 0)
      }
    end
    zatladder.sort_by { |id| id[:spendings] }.reverse!
  end
end
