module Debit
  class Transaction < ApplicationRecord
    self.table_name = 'debit_transactions'

    belongs_to :user
    belongs_to :collection, class_name: 'Debit::Collection'
    belongs_to :mandate, class_name: 'Debit::Mandate'

    validates :description, :amount, :status, presence: true
    validates :amount, numericality: { less_than: 0, message: 'must be negative for direct debit' }
    validates :status, inclusion: { in: %w[pending success failed] }
    validate :mandate_must_be_active

    scope :for_user, ->(user) { where(user: user) }
    scope :pending, -> { where(status: 'pending') }
    scope :successful, -> { where(status: 'success') }
    scope :failed, -> { where(status: 'failed') }

    before_validation :set_default_mandate, on: :create
    before_validation :set_default_description, on: :create

    def absolute_amount
      amount.abs
    end

    private

    def mandate_must_be_active
      return unless mandate.present?

      errors.add(:mandate, 'must be active') unless mandate.active?
    end

    def set_default_mandate
      return if mandate.present?

      # Find the user's active mandate
      active_mandate = user.debit_mandates.active.first if user.present?
      self.mandate = active_mandate if active_mandate.present?
    end

    def set_default_description
      return if description.present?

      self.description = "SEPA incasso #{collection&.name || 'Sofia'}"
    end
  end
end
