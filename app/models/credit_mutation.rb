class CreditMutation < ApplicationRecord
  belongs_to :user
  belongs_to :activity, optional: true

  validates :description, presence: true
  validates :user, presence: true
  validates :amount, presence: true
end
