class ProductPriceController < ApplicationController
  def show
    super
    render json: @model
  end

  def update
    authorize @model

    if @model.update(permitted_attributes)
      render json: @model
    else
      respond_bip_error(@model)
    end
  end

  private

  def model_params
    [:price]
  end
end
