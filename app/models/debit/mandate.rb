module Debit
  class Mandate < ApplicationRecord
    self.table_name = 'debit_mandates'

    belongs_to :user
    has_many :transactions, class_name: 'Debit::Transaction', foreign_key: 'mandate_id', dependent: :restrict_with_error

    validates :iban, :iban_holder, :mandate_reference, :start_date, presence: true
    validates :mandate_reference, uniqueness: true
    validates :iban, format: { with: /\A[A-Z]{2}[0-9]{2}[A-Z0-9]+\z/, message: 'must be a valid IBAN format' }
    validate :end_date_after_start_date

    scope :active, lambda {
      where('start_date <= ? AND (end_date IS NULL OR end_date >= ?)', Date.current, Date.current)
        .where(deleted_at: nil)
    }
    scope :for_user, ->(user) { where(user: user) }

    before_validation :generate_mandate_reference, on: :create
    before_validation :normalize_iban

    def active?
      deleted_at.nil? &&
        start_date <= Date.current &&
        (end_date.nil? || end_date >= Date.current)
    end

    def to_s
      "#{iban_holder} - #{formatted_iban}"
    end

    def formatted_iban
      iban.to_s.scan(/.{1,4}/).join(' ')
    end

    private

    def end_date_after_start_date
      return unless end_date.present? && start_date.present?

      errors.add(:end_date, 'must be after start date') if end_date < start_date
    end

    def generate_mandate_reference
      return if mandate_reference.present?

      # Generate unique reference like "SOFIA-2026-001234"
      year = Date.current.year
      last_number = Debit::Mandate.where('mandate_reference LIKE ?', "SOFIA-#{year}-%")
                                   .maximum('mandate_reference')
                                   &.split('-')
                                   &.last
                                   &.to_i || 0
      self.mandate_reference = format('SOFIA-%d-%06d', year, last_number + 1)
    end

    def normalize_iban
      self.iban = iban.to_s.upcase.gsub(/\s+/, '') if iban.present?
    end
  end
end
