class Product < ApplicationRecord
  has_many :prices, source: :product_price, dependent: :destroy
  validates :name, presence: true
end
