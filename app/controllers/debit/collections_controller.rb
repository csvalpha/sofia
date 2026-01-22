module Debit
  class CollectionsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_collection, only: %i[show generate download]
    after_action :verify_authorized

    def index
      authorize Debit::Collection
      @collections = policy_scope(Debit::Collection)
                       .includes(:author, :transactions)
                       .order(collection_date: :desc)
                       .page(params[:page])

      @pending_collections = @collections.pending
      @completed_collections = @collections.completed
    end

    def show
      @transactions = @collection.transactions
                                 .includes(:user, :mandate)
                                 .order('users.name')
    end

    def generate
      authorize @collection, :generate?

      begin
        @collection.generate_sepa_file!
        redirect_to debit_collection_path(@collection), 
                    flash: { success: 'SEPA bestand succesvol gegenereerd' }
      rescue StandardError => e
        redirect_to debit_collection_path(@collection), 
                    flash: { error: "Fout bij genereren: #{e.message}" }
      end
    end

    def download
      authorize @collection, :download?

      sepa_xml = @collection.download_sepa_file
      
      if sepa_xml.present?
        send_data sepa_xml,
                  filename: "sepa_#{@collection.collection_date.strftime('%Y%m%d')}_#{@collection.id}.xml",
                  type: 'application/xml',
                  disposition: 'attachment'
      else
        redirect_to debit_collection_path(@collection),
                    flash: { error: 'Geen SEPA bestand beschikbaar. Genereer eerst een bestand.' }
      end
    end

    private

    def set_collection
      @collection = Debit::Collection.find(params[:id])
      authorize @collection
    end
  end
end
