class Order < ApplicationRecord
  belongs_to :activity
  belongs_to :user
  belongs_to :created_by, class_name: 'User'

  has_many :order_rows, dependent: :destroy
  accepts_nested_attributes_for :order_rows

  validates :activity, :user, :created_by, presence: true

  def order_total
    @sum ||= order_rows.map(&:row_total).sum
  end

  def created_at_time
    created_at.strftime('%H:%M')
  end
end
