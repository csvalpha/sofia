class Order < ApplicationRecord
  belongs_to :activity
  belongs_to :user

  has_many :order_rows, dependent: :destroy

  validates :activity, :user, presence: true

  def order_total
    sum = 0
    order_rows.each do |row|
      sum += row.price_per_product * row.product_count
    end
    sum
  end
end
