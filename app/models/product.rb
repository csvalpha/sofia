class Product < ApplicationRecord
  has_many :product_prices, dependent: :destroy
  has_many :price_lists, through: :product_prices, dependent: :restrict_with_error
  validates :name, presence: true
  validates :requires_age, inclusion: [true, false]
  validates :category, presence: true, inclusion: {
    in: %w[bier fris gedestilleerd wijn food sigaren]
  }

  accepts_nested_attributes_for :product_prices
end
