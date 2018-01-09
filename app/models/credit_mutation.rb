class CreditMutation < ApplicationRecord
  belongs_to :user
  belongs_to :activity, optional: true
  belongs_to :created_by, class_name: 'User'

  validates :description, presence: true
  validates :user, presence: true
  validates :created_by, presence: true
  validates :amount, presence: true
  validate :activity_allows_orders

  def activity_allows_orders
    return true unless activity
    return true unless activity.closed?
    errors.add(:activity, 'closed longer then a month ago, cannot create new orders')
    false
  end
end
