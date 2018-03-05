class ProductsController < ApplicationController
  before_action :set_model, only: %i[show update]
  before_action :authenticate_user!

  after_action :verify_authorized

  def show
    authorize @product
  end

  def create
    @product = Product.new(permitted_attributes)
    authorize @product

    if @product.save
      render json: @product, include: json_includes, except: json_exludes, methods: :t_category
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def update
    authorize @product

    if @product.update(permitted_attributes)
      render json: @product, include: json_includes, except: json_exludes, methods: :t_category
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  private

  def set_model
    @product = Product.find(params[:id])
  end

  def permitted_attributes
    params.require(:product)
          .permit(%i[name category requires_age], product_prices_attributes: %i[id product_id price_list_id price])
  end

  def json_includes
    { product_prices: { except: %i[created_at updated_at deleted_at] } }
  end

  def json_exludes
    %i[created_at updated_at deleted_at]
  end
end
