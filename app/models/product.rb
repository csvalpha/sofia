class Product < ApplicationRecord
  has_many :prices, source: :product_price, dependent: :destroy
  has_many :price_lists, through: :prices
  validates :name, presence: true
end
