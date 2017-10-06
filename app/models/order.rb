class Order < ApplicationRecord
  belongs_to :activity
  belongs_to :user

  has_many :order_rows, dependent: :destroy

  validates :activity, :user, presence: true

  def recalculate_order_total
    update(order_total: order_rows&.map(&:product_price_total)&.inject(:+) || 0)
  end
end
