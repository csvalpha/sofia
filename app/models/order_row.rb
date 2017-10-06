class OrderRow < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :order, :product, presence: true
  validates :product_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :product_price_total, numericality: { greater_than: 0, allow_nil: true }

  validate :product_available_in_activity?
  validate :no_changes_of_product_count_allowed
  validate :no_changes_of_product_price_total_allowed

  before_save :calculate_product_price_total
  after_save :recalculate_order_total

  def calculate_product_price_total
    self.product_price_total = order.activity.price_list.product_price_for(product)&.amount.try(:*, product_count) || 0
  end

  delegate :recalculate_order_total, to: :order

  def product_available_in_activity?
    errors.add(:product, 'must be in activity\'s price list') unless
      order&.activity&.price_list&.products&.include?(product)
  end

  def no_changes_of_product_count_allowed
    errors.add(:product_count, 'cannot be altered') if !new_record? && product_count_changed?
  end

  def no_changes_of_product_price_total_allowed
    errors.add(:product_price_total, 'cannot be altered') if !new_record? && product_price_total_changed?
  end
end
