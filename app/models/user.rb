class User < ApplicationRecord
  has_many :transactions
  validates :username, presence: true
end
