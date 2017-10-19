class ProductsController < ApplicationController
  before_action :set_model, only: %i[show update destroy]
  before_action :authenticate_user!

  def model_class
    Product
  end
end
