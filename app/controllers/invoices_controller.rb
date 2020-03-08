class InvoicesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    authorize Invoice

    @invoices = Invoice.all
    @activities_json = Activity.all.to_json(only: %i[id title])
    @invoice = Invoice.new

  end

  def create
    @invoice = Invoice.new(permitted_attributes)
    authorize @invoice

    if @invoice.save
      flash[:success] = 'Successfully created invoice'
    else
      flash[:error] = @invoice.errors.full_messages.join(', ')
    end
  end

  private

  def permitted_attributes
    params.require(:invoice).permit(%i[user activity])
  end
end
