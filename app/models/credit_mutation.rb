class CreditMutation < ApplicationRecord
  belongs_to :user
  belongs_to :activity, optional: true
  belongs_to :created_by, class_name: 'User', inverse_of: :credit_mutations

  validates :description, :user, :created_by, :amount, presence: true

  validate :activity_not_locked

  def activity_not_locked
    return if activity.blank?

    errors.add(:activity, 'has been locked') if changed? && activity.locked?
  end
end
