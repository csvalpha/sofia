module Debit
  class Collection < ApplicationRecord
    self.table_name = 'debit_collections'

    belongs_to :author, class_name: 'User', optional: true
    has_many :transactions, class_name: 'Debit::Transaction', foreign_key: 'collection_id', dependent: :destroy

    validates :name, :collection_date, :status, presence: true
    validates :status, inclusion: { in: %w[pending processing completed failed] }
    validate :collection_date_not_in_past, on: :create

    scope :for_user, lambda { |user|
      joins(:transactions).where(debit_transactions: { user_id: user.id }).distinct
    }
    scope :pending, -> { where(status: 'pending') }
    scope :completed, -> { where(status: 'completed') }
    scope :recent, -> { order(collection_date: :desc) }

    def total_amount
      transactions.sum(:amount)
    end

    def transaction_count
      transactions.count
    end

    def user_count
      transactions.select(:user_id).distinct.count
    end

    def can_generate?
      pending? && collection_date >= Date.current && transactions.any?
    end

    def generate_sepa_file!
      return unless can_generate?

      update!(status: 'processing')
      
      begin
        sepa_xml = Debit::SepaGenerator.new(self).generate
        update!(
          sepa_file_content: sepa_xml,
          status: 'completed'
        )
        sepa_xml
      rescue StandardError => e
        update!(status: 'failed')
        raise e
      end
    end

    def download_sepa_file
      return unless sepa_file_content.present?

      sepa_file_content
    end

    def to_s
      name
    end

    private

    def collection_date_not_in_past
      return unless collection_date.present?

      errors.add(:collection_date, 'cannot be in the past') if collection_date < Date.current
    end
  end
end
