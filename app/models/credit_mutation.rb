class CreditMutation < ApplicationRecord
  belongs_to :user
  belongs_to :activity, optional: true
  belongs_to :created_by, class_name: 'User', inverse_of: :credit_mutations

  validates :description, :user, :created_by, presence: true
  validates :amount, presence: true, numericality: { less_than_or_equal_to: 1000 }

  validate :activity_not_locked

  before_destroy -> { throw(:abort) }

  def activity_not_locked
    return if activity.blank?

    errors.add(:activity, 'has been locked') if changed? && activity.locked?
  end
end
