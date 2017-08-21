class Product < ApplicationRecord
  has_many :prices, source: :product_price
  validates :name, presence: true
end
