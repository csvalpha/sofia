module Debit
  class SepaGenerator
    attr_reader :collection

    def initialize(collection)
      @collection = collection
    end

    def generate
      raise 'Collection must have transactions' if collection.transactions.empty?
      raise 'Collection date must be in the future or today' if collection.collection_date < Date.current

      # Create SEPA Direct Debit object
      sdd = SEPA::DirectDebit.new(
        name: creditor_name,
        iban: creditor_iban,
        creditor_identifier: creditor_identifier,
        requested_date: collection.collection_date,
        reference: collection_reference,
        batch_booking: true
      )

      # Add transactions
      collection.transactions.includes(:user, :mandate).find_each do |transaction|
        validate_transaction!(transaction)

        sdd.add_transaction(
          name: transaction.mandate.iban_holder,
          iban: transaction.mandate.iban,
          amount: transaction.absolute_amount,
          mandate_id: transaction.mandate.mandate_reference,
          mandate_date_of_signature: transaction.mandate.start_date,
          remittance_information: transaction.description,
          reference: transaction_reference(transaction),
          requested_date: collection.collection_date
        )
      end

      # Generate XML
      sdd.to_xml
    end

    private

    def creditor_name
      Rails.application.config.x.company_name || 'Sofia'
    end

    def creditor_iban
      Rails.application.config.x.sepa_creditor_iban || 
        ENV['SEPA_CREDITOR_IBAN'] ||
        raise('SEPA creditor IBAN not configured. Set SEPA_CREDITOR_IBAN in .env')
    end

    def creditor_identifier
      Rails.application.config.x.sepa_creditor_identifier ||
        ENV['SEPA_CREDITOR_IDENTIFIER'] ||
        raise('SEPA creditor identifier not configured. Set SEPA_CREDITOR_IDENTIFIER in .env')
    end

    def collection_reference
      "COLL-#{collection.id}-#{collection.collection_date.strftime('%Y%m%d')}"
    end

    def transaction_reference(transaction)
      "TXN-#{transaction.id}-#{transaction.user_id}"
    end

    def validate_transaction!(transaction)
      raise "Transaction #{transaction.id}: mandate is not active" unless transaction.mandate.active?
      raise "Transaction #{transaction.id}: amount must be negative" unless transaction.amount.negative?
      raise "Transaction #{transaction.id}: IBAN is invalid" if transaction.mandate.iban.blank?
    end
  end
end
