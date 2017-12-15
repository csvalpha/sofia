class PriceListsController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized

  autocomplete :price_list, :name, full: true

  def index
    recent_price_lists = PriceList.order(created_at: :desc).limit(5)
    products = Product.all.order(:id).includes(:product_prices)

    authorize recent_price_lists

    @price_list = PriceList.new

    @recent_price_lists_json = recent_price_lists.to_json(except: %i[created_at updated_at deleted_at])
    @products_json = products.to_json(include: { product_prices: { except: %i[created_at updated_at deleted_at] } },
                                      except: %i[created_at updated_at deleted_at])
  end

  def show
    @price_list = PriceList.includes(model_includes).find(params[:id])
    @products = Product.all.order(:id)
    authorize @price_list
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
    redirect_to @price_list
  end

  private

  def model_includes
    [:product_price, :activities, product_price: :product]
  end

  def permitted_attributes
    params.require(:price_list).permit(:name)
  end
end
