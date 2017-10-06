class PriceListsController < ApplicationController
  before_action :set_model, only: %i[show update destroy]

  autocomplete :price_list, :name, full: true

  def index
    @recent_price_lists = PriceList.order(:created_at).limit(6).includes(model_includes) || []
    @products = @recent_price_lists.map(&:products).flatten.uniq.sort_by(&:created_at)
  end

  def model_class
    PriceList
  end
end
