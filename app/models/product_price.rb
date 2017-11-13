class ProductPrice < ApplicationRecord
  belongs_to :product
  belongs_to :price_list

  validates :price, presence: true
  validates :product_id, uniqueness: { scope: :price_list_id }

  delegate :name, to: :product
end
