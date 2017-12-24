class ActivitiesController < ApplicationController
  def index
    super
    @new_model = Activity.new(
      start_time: (Time.zone.now + 2.hours).beginning_of_hour,
      end_time: (Time.zone.now + 6.hours).beginning_of_hour
    )
  end

  private

  def model_includes
    [:price_list, orders: %i[user order_rows]]
  end

  def model_params
    %i[title start_time end_time price_list_id]
  end
end
