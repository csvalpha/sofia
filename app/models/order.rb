class Order < ApplicationRecord
  belongs_to :activity
  belongs_to :user, optional: true
  belongs_to :created_by, class_name: 'User'

  has_many :order_rows, dependent: :destroy
  accepts_nested_attributes_for :order_rows

  validates :paid_with_cash, inclusion: [true, false]
  validates :paid_with_pin, inclusion: [true, false]

  validate :user_or_cash_or_pin
  validate :activity_not_locked

  before_create :can_user_create_order?
  before_destroy -> { throw(:abort) }

  scope :orders_for, ->(user) { where(user:) }

  def can_user_create_order?
    throw(:abort) unless user.nil? || user.can_order(activity)
  end

  def order_total
    @sum ||= order_rows.sum('product_count * price_per_product')
  end

  def self.count_per_product(from_date, to_date)
    records = Order.where(created_at: from_date..to_date)

    order_rows = OrderRow.where(order: records).group(:product_id, :name).joins(:product)
                         .pluck(:name, Arel.sql('SUM(product_count)'), Arel.sql('SUM(product_count * price_per_product)'))
    order_rows.map { |name, amount, price| { name:, amount: amount.to_i, price: price.to_f } }
  end

  def self.count_per_category(from_date, to_date)
    records = Order.where(created_at: from_date..to_date)

    order_rows = OrderRow.where(order: records).group(:category).joins(:product)
                         .pluck(:category, Arel.sql('SUM(product_count)'), Arel.sql('SUM(product_count * price_per_product)'))

    order_rows.map { |category, amount, price| { category:, amount: amount.to_i, price: price.to_f } }
  end

  private

  def user_or_cash_or_pin
    errors.add(:order, 'must belong to a user or was paid in cash or with pin') unless user || paid_with_cash || paid_with_pin
  end

  def activity_not_locked
    errors.add(:activity, 'has been locked') if changed? && activity.locked?
  end
end
