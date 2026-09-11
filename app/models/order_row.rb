class OrderRow < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :product_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :price_per_product, numericality: { greater_than: 0, allow_nil: true }
  validates :product, inclusion: { in: :available_products }

  validate :no_changes_of_product_count_allowed
  validate :no_changes_of_price_per_product_allowed

  before_create :copy_product_price

  before_destroy -> { throw(:abort) }

  def copy_product_price
    self.price_per_product = order.activity.price_list.product_price_for(product).price
  end

  def no_changes_of_product_count_allowed
    return unless !new_record? && product_count_changed? && order.activity.locked?

    errors.add(:product_count, 'cannot be altered because the activity is locked')
  end

  def no_changes_of_price_per_product_allowed
    errors.add(:price_per_product, 'cannot be altered') if !new_record? && price_per_product_changed?
  end

  def available_products
    order ? order.activity.price_list.products : []
  end
end
