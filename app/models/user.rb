class User < ApplicationRecord
  has_many :orders, dependent: :destroy
  validates :username, presence: true

  def credit
    credit = 0
    orders.each do |order|
      credit -= order.order_total
    end
    credit
  end
end
