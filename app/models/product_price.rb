class ProductPrice < ApplicationRecord
  belongs_to :product, touch: true
  belongs_to :price_list, touch: true

  validates :amount, presence: true
end
