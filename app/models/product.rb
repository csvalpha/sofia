class Product < ApplicationRecord
  has_many :product_price, dependent: :destroy
  has_many :price_lists, through: :prices, dependent: :restrict_with_error
  validates :name, :contains_alcohol, presence: true
end
