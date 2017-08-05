class PriceList < ApplicationRecord
  has_many :product_price
  has_many :products, through: :product_price

  validates :name, presence: true
end
