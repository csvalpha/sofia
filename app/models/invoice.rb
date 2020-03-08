class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :activity

  validates :user, :activity, :amount, presence: true
end
