class ProductsController < ApplicationController
  before_action :set_model, only: %i[show update destroy]
  before_action :authenticate_user!

  def model_class
    Product
  end

  def show; end

  def create
    @product = Product.new(permitted_attributes)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product }
        format.json { render json: @product, include: { product_prices: { except: %i[created_at updated_at deleted_at] } }, except: %i[created_at updated_at deleted_at] }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_team
    @product = Product.find(params[:id])
  end

  def permitted_attributes
    params.require(:product).permit(%i[name contains_alcohol], product_prices_attributes: %i[price_list_id price])
  end
end
