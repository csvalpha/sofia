class ProductsController < ApplicationController
  before_action :set_model, only: %i[update]
  before_action :authenticate_user!

  after_action :verify_authorized

  def create
    @product = Product.new(product_params)
    authorize @product

    if @product.save
      render json: @product, include: json_includes, except: json_exludes, methods: :t_category
    else
      render json: @product.errors, status: :unprocessable_content
    end
  end

  def update
    authorize @product

    if @product.update(product_params)
      render json: @product, include: json_includes, except: json_exludes, methods: :t_category
    else
      render json: @product.errors, status: :unprocessable_content
    end
  end

  private

  def set_model
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(policy(Product).permitted_attributes)
  end

  def json_includes
    { product_prices: { except: %i[created_at updated_at deleted_at] } }
  end

  def json_exludes
    %i[created_at updated_at deleted_at]
  end
end
