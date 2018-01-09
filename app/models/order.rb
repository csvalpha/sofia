class Order < ApplicationRecord
  belongs_to :activity
  belongs_to :user
  belongs_to :created_by, class_name: 'User'

  has_many :order_rows, dependent: :destroy
  accepts_nested_attributes_for :order_rows

  validates :activity, :user, :created_by, presence: true
  validate :activity_allows_orders

  def order_total
    @sum ||= order_rows.map(&:row_total).sum
  end

  private

  def activity_allows_orders
    return true if activity&.activity_not_long_ago
    errors.add(:activity, 'closed longer then a month ago, cannot create new orders')
    false
  end
end
