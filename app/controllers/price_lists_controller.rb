class PriceListsController < ApplicationController
  before_action :set_model, only: %i[show update destroy]

  autocomplete :price_list, :name, { full: true }

  def model_class
    PriceList
  end
end
