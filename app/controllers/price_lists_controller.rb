class PriceListsController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize PriceList

    price_lists = policy_scope(PriceList.order(created_at: :desc))
    products = Product.order(:id).includes(:product_prices)

    @price_list = PriceList.new

    @price_lists_json = price_lists.to_json(except: %i[created_at updated_at deleted_at])
    @products_json = products.to_json(
      include: { product_prices: { except: %i[created_at updated_at deleted_at] } },
      methods: :t_category,
      except: %i[created_at updated_at deleted_at]
    )
  end

  def create
    @price_list = PriceList.new(permitted_attributes)
    authorize @price_list

    if @price_list.save
      flash[:success] = 'Prijslijst aangemaakt'
    else
      flash[:error] = "Prijslijst aanmaken mislukt; #{@price_list.errors.full_messages.join(', ')}"
    end
    redirect_to price_lists_path
  end

  def update
    @price_list = PriceList.find(params[:id])
    authorize @price_list

    if @price_list.update(permitted_attributes)
      flash[:success] = 'Prijslijst opgeslagen'
    else
      flash[:error] = "Prijslijst wijzigen mislukt; #{@price_list.errors.full_messages.join(', ')}"
    end
    redirect_to price_lists_path
  end

  def archive
    @price_list = PriceList.find(params[:id])
    authorize @price_list

    @price_list.archived_at = Time.zone.now

    respond_to do |format|
      if @price_list.save
        format.json { render json: @price_list.archived_at }
      else
        format.json { render json: @price_list.errors, status: :unprocessable_content }
      end
    end
  end

  def unarchive
    @price_list = PriceList.find(params[:id])
    authorize @price_list

    @price_list.archived_at = nil

    respond_to do |format|
      if @price_list.save
        format.json { render json: @price_list.archived_at }
      else
        format.json { render json: @price_list.errors, status: :unprocessable_content }
      end
    end
  end

  private

  def permitted_attributes
    params.require(:price_list).permit(:name)
  end
end
