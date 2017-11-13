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
        format.json { render json: @product, include: json_includes, except: json_exludes }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @product.update(permitted_attributes)
        format.html { redirect_to @product, notice: 'Team was successfully updated.' }
        format.json { render json: @product, include: json_includes, except: json_exludes }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_model
    @product = Product.find(params[:id])
  end

  def permitted_attributes
    params.require(:product)
          .permit(%i[name requires_age], product_prices_attributes: %i[id product_id price_list_id price])
  end

  def json_includes
    { product_prices: { except: %i[created_at updated_at deleted_at] } }
  end

  def json_exludes
    %i[created_at updated_at deleted_at]
  end
end
