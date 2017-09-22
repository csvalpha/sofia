class Transaction < ApplicationRecord
  belongs_to :product
  belongs_to :activity
  belongs_to :user

  validates :amount, presence: true
  validates :timestamp, presence: true
  validates :user, presence: true

  validate :no_changes_of_amount_allowed

  def no_changes_of_amount_allowed
    errors.add(:amount, 'cannot be altered') if !new_record? && amount_changed?
  end
end
