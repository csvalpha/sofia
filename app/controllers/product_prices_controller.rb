class ProductPricesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product_price, only: %i[assign_folder]
  before_action :set_price_list, only: %i[reorder]

  def assign_folder # rubocop:disable Metrics/MethodLength
    authorize @product_price, :update?

    folder_id = params[:folder_id]

    if folder_id.present?
      folder = ProductPriceFolder.find_by(id: folder_id)
      unless folder
        return render json: { errors: ['Folder not found'] }, status: :unprocessable_content
      end
      unless folder.price_list_id == @product_price.price_list_id
        return render json: { errors: ['Folder does not belong to the same price list'] }, status: :unprocessable_content
      end
    end

    if @product_price.update(product_price_folder_id: folder_id)
      render json: @product_price, include: product_price_includes
    else
      render json: { errors: @product_price.errors.full_messages }, status: :unprocessable_content
    end
  end

  def reorder # rubocop:disable Metrics/MethodLength
    product_positions = params.require(:product_positions)

    ActiveRecord::Base.transaction do
      product_positions.each do |product_data|
        product_price = @price_list.product_prices.find(product_data[:id])
        authorize product_price, :update?
        product_price.update!(
          position: product_data[:position],
          product_price_folder_id: product_data[:folder_id]
        )
      end
    end

    render json: { success: true }
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: [e.message] }, status: :unprocessable_content
  end

  private

  def set_product_price
    @product_price = ProductPrice.find(params[:id])
  end

  def set_price_list
    @price_list = PriceList.find(params[:price_list_id])
  end

  def product_price_includes
    { product: { only: %i[id name category color], methods: %i[requires_age] } }
  end
end
