class ZatladderController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    authorize :zatladder

    @from_date  = last_october
    @to_date    = last_october + 1.year
    @zatladder = zatladder_spendings(@from_date, @to_date)
  end

  private

  def last_october
    # now: 04 - 05 - 2018
    beginning_of_year = Time.zone.now.beginning_of_year
    return beginning_of_year - 3.months if Time.zone.now < beginning_of_year + 9.months

    beginning_of_year + 10.months
  end

  def zatladder_spendings(from, to)
    @users_spendings = User.in_banana.calculate_spendings(from: from, to: to)
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
