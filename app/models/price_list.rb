class PriceList < ApplicationRecord
  has_many :product_price, dependent: :destroy
  has_many :products, through: :product_price, dependent: :destroy

  validates :name, presence: true

  def product_price_for(product)
    product_price.find_by(product: product)
  end

  def activities
    Activity.where(price_list: self).order(:start_time)
  end

  def to_s
    name
  end
end
