class OrderRow < ApplicationRecord
  belongs_to :order, inverse_of: :order_rows
  belongs_to :product

  validates :order, :product, presence: true
  validates :product_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price_per_product, numericality: { greater_than: 0, allow_nil: true }
  validates :product, inclusion: { in: :available_products }

  validate :no_changes_of_product_count_allowed
  validate :no_changes_of_price_per_product_allowed

  before_create :copy_product_price

  def copy_product_price
    self.price_per_product = order.activity.price_list.product_price_for(product).price
  end

  def no_changes_of_product_count_allowed
    errors.add(:product_count, 'cannot be altered') if !new_record? && product_count_changed?
  end

  def no_changes_of_price_per_product_allowed
    errors.add(:price_per_product, 'cannot be altered') if !new_record? && price_per_product_changed?
  end

  def available_products
    order ? order.activity.price_list.products : []
  end

  def row_total
    price_per_product * product_count
  end
end
