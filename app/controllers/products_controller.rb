class ProductsController < ApplicationController
  def create
    @model = model_class.new(permitted_attributes)
    authorize @model

    if @model.save
      render json: @model, include: json_includes, except: json_exludes
    else
      render json: @model.errors, status: :unprocessable_entity
    end
  end

  def update
    authorize @model

    if @model.update(permitted_attributes)
      render json: @model, include: json_includes, except: json_exludes
    else
      render json: @model.errors, status: :unprocessable_entity
    end
  end

  private

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
