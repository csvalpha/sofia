class PriceList < ApplicationRecord
  has_many :product_price
  has_many :products, through: :product_price

  validates :name, presence: true

  def product_price_for(product)
    product_price.find_by(product: product)
  end

  def to_s
    name
  end
end
