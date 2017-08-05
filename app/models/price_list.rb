class PriceList < ApplicationRecord
  has_many :product_price
  has_many :products, through: :product_price
  validates :title, presence: true
end
