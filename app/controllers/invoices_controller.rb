class InvoicesController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_user!, except: %w[show pay]
  after_action :verify_authorized, except: %w[show pay]

  def index
    authorize Invoice

    @invoices = Invoice.includes(:user, :activity, :rows).order(created_at: :desc)
    @activities_json = Activity.all.to_json(only: %i[id title start_time])
    @invoice = Invoice.new
    @invoice.rows.build
  end

  def show
    @invoice = invoice
    token_based_access = !integer_id?(params[:id])

    # Authorize for authenticated access (integer ID), skip for token-based access
    authorize @invoice, :show? unless token_based_access

    # Hide navbar when generating PDF
    @show_navigationbar = params[:pdf].blank?
    @show_extras = params[:pdf].blank?

    respond_to do |format|
      format.html
      format.pdf { render_invoice_pdf }
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

  def pay # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @invoice = invoice
    token_based_access = !integer_id?(params[:id])

    authorize @invoice, :pay? unless token_based_access

    if @invoice.paid?
      redirect_to invoice_path params[:id]
      return
    end

    payment = Payment.create_with_mollie("Betaling factuur #{@invoice.human_id}",
                                         invoice: @invoice, amount: @invoice.amount)

    if payment.valid?
      checkout_url = payment.mollie_payment.checkout_url
      redirect_to URI.parse(checkout_url).to_s, allow_other_host: true
    else
      flash[:error] = payment.errors
      redirect_to invoice_path params[:id]
    end
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

  def integer_id?(id)
    Integer(id)
    true
  rescue ArgumentError
    false
  end

  def invoice
    @invoice = Invoice.find(Integer(params[:id]))
  rescue ArgumentError
    @invoice = Invoice.find_by!(token: params[:id])
  end

  def permitted_attributes
    params.require(:invoice).permit(%i[user_id activity_id name_override email_override rows], rows_attributes: %i[name amount price])
  end

  def render_invoice_pdf
    token_based_access = !integer_id?(params[:id])
    authorize @invoice, :download? unless token_based_access

    # Use token-based URL for unauthenticated Grover access
    url = invoice_url(@invoice.token, pdf: true)
    pdf = Grover.new(url).to_pdf
    send_data pdf, filename: "Factuur-#{@invoice.human_id}.pdf", type: 'application/pdf', disposition: 'attachment'
  rescue StandardError => e
    Rails.logger.error "Failed to generate PDF for invoice #{@invoice.id}: #{e.message}"
    if request.format.pdf?
      render plain: 'Er is een fout opgetreden bij het genereren van de PDF. Probeer het later opnieuw.', status: :internal_server_error
    else
      flash[:error] = 'Er is een fout opgetreden bij het genereren van de PDF. Probeer het later opnieuw.'
      redirect_to invoice_path(@invoice)
    end
  end
end
