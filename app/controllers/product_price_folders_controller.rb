class ProductPriceFoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_price_list, only: %i[index create reorder]
  before_action :set_folder, only: %i[update destroy]

  # GET /price_lists/:price_list_id/product_price_folders
  def index
    authorize ProductPriceFolder
    @folders = @price_list.product_price_folders.order(:position)
    render json: @folders
  end

  # POST /price_lists/:price_list_id/product_price_folders
  def create
    @folder = @price_list.product_price_folders.new(folder_params)
    authorize @folder

    if @folder.save
      render json: @folder, status: :created
    else
      render json: { errors: @folder.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /product_price_folders/:id
  def update
    authorize @folder

    if @folder.update(folder_params)
      render json: @folder
    else
      render json: { errors: @folder.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /product_price_folders/:id
  def destroy
    authorize @folder

    # Move all products in this folder back to home screen (nullify folder_id)
    @folder.product_prices.update_all(product_price_folder_id: nil)
    @folder.destroy

    head :no_content
  end

  # PATCH /price_lists/:price_list_id/product_price_folders/reorder
  def reorder
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
    render json: { errors: [e.message] }, status: :unprocessable_entity
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
