class Product < ApplicationRecord
  has_many :product_prices, dependent: :destroy
  has_many :price_lists, through: :product_prices, dependent: :restrict_with_error
  validates :name, presence: true
  validates :requires_age, inclusion: [true, false]
  validates :category, presence: true

  enum category: {bier: 0, fris: 1, gedestileerd: 2, wijn: 3, eten: 4, sigaren: 5}

  accepts_nested_attributes_for :product_prices
end
