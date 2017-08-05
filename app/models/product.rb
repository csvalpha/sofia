class Product < ApplicationRecord
  has_many :prices, source: :product_price
  validates :title, presence: true
end
