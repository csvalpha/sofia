class Order < ApplicationRecord
  belongs_to :activity
  belongs_to :user, optional: true
  belongs_to :created_by, class_name: 'User', inverse_of: :orders

  has_many :order_rows, dependent: :destroy
  accepts_nested_attributes_for :order_rows

  validates :activity, :created_by, presence: true
  validates :paid_with_cash, inclusion: [true, false]
  validates :paid_with_pin, inclusion: [true, false]

  validate :user_or_cash_or_pin
  validate :activity_not_locked

  before_destroy -> { throw(:abort) }

  scope :orders_for, (->(user) { where(user: user) })

  def order_total
    @sum ||= order_rows.sum('product_count * price_per_product')
  end

  private

  def user_or_cash_or_pin
    errors.add(:order, 'must belong to a user or was paid in cash or with pin') unless user || paid_with_cash || paid_with_pin
  end

  def activity_not_locked
    errors.add(:activity, 'has been locked') if changed? && activity.locked?
  end
end
