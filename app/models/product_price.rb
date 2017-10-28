class ProductPrice < ApplicationRecord
  belongs_to :product, touch: true
  belongs_to :price_list, touch: true

  validates :price, presence: true

  delegate :name, to: :product
end
