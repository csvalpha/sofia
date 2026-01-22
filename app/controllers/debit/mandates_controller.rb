module Debit
  class MandatesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_mandate, only: %i[show edit update destroy]
    after_action :verify_authorized

    def index
      authorize Debit::Mandate
      @mandates = policy_scope(Debit::Mandate)
                    .includes(:user)
                    .order(created_at: :desc)
                    .page(params[:page])

      @mandate = Debit::Mandate.new if current_user&.treasurer? || @mandates.none?
    end

    def show
      # @mandate set by before_action
    end

    def new
      @mandate = Debit::Mandate.new
      @mandate.user = current_user unless current_user&.treasurer?
      authorize @mandate
    end

    def edit
      # @mandate set by before_action
    end

    def create
      @mandate = Debit::Mandate.new(mandate_params)
      @mandate.user = current_user unless current_user&.treasurer?
      authorize @mandate

      if @mandate.save
        redirect_to debit_mandates_path, flash: { success: 'Mandaat succesvol aangemaakt' }
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @mandate.update(mandate_params)
        redirect_to debit_mandate_path(@mandate), flash: { success: 'Mandaat succesvol bijgewerkt' }
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @mandate.update(deleted_at: Time.current)
      redirect_to debit_mandates_path, flash: { success: 'Mandaat succesvol verwijderd' }
    end

    private

    def set_mandate
      @mandate = Debit::Mandate.find(params[:id])
      authorize @mandate
    end

    def mandate_params
      if current_user&.treasurer?
        params.require(:debit_mandate).permit(:user_id, :iban, :iban_holder, :start_date, :end_date)
      else
        params.require(:debit_mandate).permit(:iban, :iban_holder, :start_date, :end_date)
      end
    end
  end
end
