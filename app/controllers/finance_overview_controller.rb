class FinanceOverviewController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    authorize :finance_overview

    @from_date = params[:from_date] || start_of_year
    @to_date = params[:to_date] || end_of_year
    @count_per_product = Order.count_per_product(@from_date, @to_date)
    @count_per_category = Order.count_per_category(@from_date, @to_date)
  end

  private

  def start_of_year
    Time.zone.now.beginning_of_year.strftime('%Y-%m-%d')
  end

  def end_of_year
    Time.zone.now.end_of_year.strftime('%Y-%m-%d')
  end
end
