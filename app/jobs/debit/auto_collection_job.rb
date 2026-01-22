module Debit
  class AutoCollectionJob < ApplicationJob
    queue_as :default

    # This job automatically creates SEPA collections for users with negative balances
    # It should be run monthly, typically a few days before the incasso date
    def perform(collection_date: nil, collection_name: nil)
      return unless Rails.application.config.x.sepa_incasso_enabled

      @collection_date = collection_date&.to_date || default_collection_date
      @collection_name = collection_name || default_collection_name

      users_to_collect = find_users_with_negative_balance
      
      return if users_to_collect.empty?

      collection = create_collection
      transactions_created = create_transactions(collection, users_to_collect)

      Rails.logger.info "AutoCollectionJob: Created collection #{collection.id} with #{transactions_created} transactions"
      
      notify_treasurers(collection, transactions_created)

      collection
    rescue StandardError => e
      Rails.logger.error "AutoCollectionJob failed: #{e.message}"
      notify_treasurers_of_error(e)
      raise
    end

    private

    def default_collection_date
      # Default to 5 business days from now
      date = Date.current
      5.times do
        date += 1.day
        date += 2.days if date.saturday? # Skip weekend
        date += 1.day if date.sunday?
      end
      date
    end

    def default_collection_name
      "Automatische incasso #{Date.current.strftime('%B %Y')}"
    end

    def find_users_with_negative_balance
      User.active
          .select { |user| user.credit.negative? }
          .select { |user| active_mandate_exists?(user) }
    end

    def active_mandate_exists?(user)
      user.debit_mandates.active.exists?
    end

    def create_collection
      Debit::Collection.create!(
        name: @collection_name,
        collection_date: @collection_date,
        author: nil, # System-generated
        status: 'pending'
      )
    end

    def create_transactions(collection, users)
      transactions_created = 0

      users.each do |user|
        next unless user.credit.negative?

        mandate = user.debit_mandates.active.first
        next unless mandate.present?

        Debit::Transaction.create!(
          user: user,
          collection: collection,
          mandate: mandate,
          description: "Automatische incasso #{@collection_name}",
          amount: user.credit, # Already negative
          status: 'pending'
        )

        transactions_created += 1
      rescue StandardError => e
        Rails.logger.error "Failed to create transaction for user #{user.id}: #{e.message}"
      end

      transactions_created
    end

    def notify_treasurers(collection, transactions_created)
      User.treasurer.each do |treasurer|
        next unless treasurer.email.present?

        Debit::CollectionMailer.collection_created_notification(
          treasurer,
          collection,
          transactions_created
        ).deliver_later
      rescue StandardError => e
        Rails.logger.error "Failed to notify treasurer #{treasurer.id}: #{e.message}"
      end
    end

    def notify_treasurers_of_error(error)
      User.treasurer.each do |treasurer|
        next unless treasurer.email.present?

        Debit::CollectionMailer.collection_creation_failed(
          treasurer,
          error.message
        ).deliver_later
      rescue StandardError => e
        Rails.logger.error "Failed to notify treasurer of error: #{e.message}"
      end
    end
  end
end
