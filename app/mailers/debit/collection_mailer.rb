module Debit
  class CollectionMailer < ApplicationMailer
    default from: -> { Rails.application.config.x.noreply_email || 'noreply@example.com' }

    def collection_created_notification(treasurer, collection, transaction_count)
      @treasurer = treasurer
      @collection = collection
      @transaction_count = transaction_count
      @total_amount = collection.total_amount

      mail(
        to: treasurer.email,
        subject: "Nieuwe SEPA incasso collectie aangemaakt: #{collection.name}"
      )
    end

    def collection_creation_failed(treasurer, error_message)
      @treasurer = treasurer
      @error_message = error_message

      mail(
        to: treasurer.email,
        subject: 'Fout bij automatische SEPA incasso generatie'
      )
    end

    def collection_generated(treasurer, collection)
      @treasurer = treasurer
      @collection = collection

      mail(
        to: treasurer.email,
        subject: "SEPA bestand gegenereerd: #{collection.name}"
      )
    end
  end
end
