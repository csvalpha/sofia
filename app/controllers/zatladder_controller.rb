class ZatladderController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    authorize :zatladder

    @year_range = 2018..current_year
    @year = params[:year] || current_year
    @from_date  = Time.zone.local(@year.to_i - 1, 10, 1)
    @to_date    = @from_date + 1.year

    @zatladder = zatladder_spendings(@from_date, @to_date)
  end

  private

  def current_year
    if Time.zone.now.month < 10
      Time.zone.now.year
    else
      Time.zone.now.year + 1
    end
  end

  def zatladder_spendings(from, to)
    @users_spendings = User.in_amber.calculate_spendings(from: from, to: to)
    zatladder = User.in_amber.select(:id, :name).map do |user|
      {
        id: user.id,
        name: user.name,
        spendings: @users_spendings.fetch(user.id, 0)
      }
    end
    zatladder.sort_by { |id| id[:spendings] }.reverse!
  end
end
