include ApplicationHelper

class InvoicesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    authorize Invoice

    @invoices = Invoice.all.order(created_at: :desc)
    @activities_json = Activity.all.to_json(only: %i[id title start_time])
    @invoice = Invoice.new
    @invoice.rows.build
  end

  def show
    @invoice = Invoice.find(params[:id])
    authorize @invoice

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Factuur #{@invoice.human_id}",
               template: 'invoices/show.html.erb',
               lowquality: true
      end
    end
  end

  def create
    attributes = remove_empty(permitted_attributes.to_h)
    @invoice = Invoice.new(attributes)
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

    InvoiceMailer.invoice_mail(@invoice).deliver_now
    @invoice.update(status: 'sent')

    flash[:success] = "Factuur verzonden naar #{@invoice.user.name}"
    redirect_to invoices_path
  end

  private

  def permitted_attributes
    params.require(:invoice).permit(%i[user_id activity_id name_override email_override rows], rows_attributes: %i[name amount price])
  end
end
