class ProductPrice < ApplicationRecord
  belongs_to :product
  belongs_to :price_list

  validates :price, presence: true

  delegate :name, to: :product
end
