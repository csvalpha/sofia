class Order < ApplicationRecord
  belongs_to :activity
  belongs_to :user

  has_many :order_rows, dependent: :destroy

  validates :activity, :user, presence: true

  def order_total
    sum = 0
    order_rows.each do |row|
      sum += row.row_total
    end
    sum
  end
end
