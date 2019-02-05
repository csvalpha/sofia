class ProductPrice < ApplicationRecord
  belongs_to :product
  belongs_to :price_list

  validates :price, presence: true
  validates :product_id, uniqueness: { scope: %i[price_list_id deleted_at] }

  delegate :name, to: :product
end
