class CreditMutation < ApplicationRecord
  belongs_to :user
  belongs_to :activity, optional: true
  belongs_to :created_by, class_name: 'User'

  validates :description, presence: true
  validates :user, presence: true
  validates :created_by, presence: true
  validates :amount, presence: true
end
