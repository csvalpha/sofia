class ProductPrice < ApplicationRecord
  belongs_to :product
  belongs_to :price_list
end
