class CreditMutation < ApplicationRecord
  belongs_to :user
  belongs_to :activity, optional: true
  belongs_to :author, class_name: 'User'

  validates :description, presence: true
  validates :user, presence: true
  validates :author, presence: true
  validates :amount, presence: true
end
