class User < ApplicationRecord
  has_many :transactions
  validates :username, presence: true

  def credit
    credit = 0
    transactions.each do |t|
      credit -= t.amount
    end
    credit
  end
end
