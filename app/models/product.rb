class Product < ApplicationRecord
  has_many :product_price, dependent: :destroy
  has_many :price_lists, through: :prices, dependent: :restrict_with_error
  validates :name, presence: true
  validates :contains_alcohol, inclusion: [true, false]
end
