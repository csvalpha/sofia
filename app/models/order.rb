class Order < ApplicationRecord
  belongs_to :activity
  belongs_to :user

  has_many :order_rows, dependent: :destroy

  validates :activity, :user, presence: true

  after_initialize :recalculate_order_total
  before_save :recalculate_order_total

  def recalculate_order_total
    self.order_total = order_rows&.map(&:product_price_total)&.inject(:+) || 0
  end
end
