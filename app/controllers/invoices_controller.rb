class InvoicesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    authorize Invoice

    @invoices = Invoice.all
    @activities_json = Activity.all.to_json(only: %i[id title])
    @invoice = Invoice.new
  end

  def show
    @invoice = Invoice.find(params[:id])
    authorize @invoice

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Factuur #{@invoice.human_id}",
               page_size: 'A4',
               template: "invoices/show.html.erb",
               layout: "pdf.html.erb",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               dpi: 75
      end
    end
  end

  def create
    @invoice = Invoice.new(permitted_attributes)
    authorize @invoice

    if @invoice.save
      flash[:success] = 'Successfully created invoice'
    else
      flash[:error] = @invoice.errors.full_messages.join(', ')
    end

    redirect_to invoices_path
  end

  def send_invoice
    @invoice = Invoice.find(params[:id])
    authorize @invoice

    InvoiceMailer.invoice_mail(@invoice)
  end

  private

  def permitted_attributes
    params.require(:invoice).permit(%i[user_id activity_id])
  end
end
