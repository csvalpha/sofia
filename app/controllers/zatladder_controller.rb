class ZatladderController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    authorize :zatladder

    last_october = Time.zone.now.beginning_of_year - 3.months

    @from_date  = last_october
    @to_date    = last_october + 1.year
    @zatladder  = zatladder_spendings(@from_date, @to_date)
  end

  private

  def zatladder_spendings(from, to)
    @users_spendings = User.calculate_spendings(from, to)
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
