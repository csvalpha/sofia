class ProductPriceFoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_price_list, only: %i[index create reorder]
  before_action :set_folder, only: %i[update destroy]

  def index
    authorize ProductPriceFolder, :index?
    @folders = @price_list.product_price_folders.order(:position)
    render json: @folders
  end

  def create
    @folder = @price_list.product_price_folders.new(folder_params)
    authorize @folder

    if @folder.save
      render json: @folder, status: :created
    else
      render json: { errors: @folder.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    authorize @folder

    if @folder.update(folder_params)
      render json: @folder
    else
      render json: { errors: @folder.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    authorize @folder

    orphaned_products = @folder.product_prices
    max_position = @folder.price_list.product_prices.without_folder.maximum(:position) || -1

    orphaned_products.each_with_index do |product_prices, index|
      product_prices.update(product_price_folder_id: nil, position: max_position + index + 1)
    end

    @folder.destroy

    head :no_content
  end

  def reorder # rubocop:disable Metrics/MethodLength
    authorize ProductPriceFolder, :reorder?

    folder_positions = params.require(:folder_positions)

    ActiveRecord::Base.transaction do
      folder_positions.each do |folder_data|
        folder = @price_list.product_price_folders.find(folder_data[:id])
        folder.update!(position: folder_data[:position])
      end
    end

    render json: { success: true }
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: [e.message] }, status: :unprocessable_content
  end

  private

  def set_price_list
    @price_list = PriceList.find(params[:price_list_id])
  end

  def set_folder
    @folder = ProductPriceFolder.find(params[:id])
  end

  def folder_params
    params.require(:product_price_folder).permit(:name, :color, :position)
  end
end
