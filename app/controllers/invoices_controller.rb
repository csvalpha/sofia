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

  def pay # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @invoice = invoice

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

  def invoice
    @invoice = Invoice.find(Integer(params[:id]))
    authorize @invoice
  rescue ArgumentError
    @invoice = Invoice.find_by!(token: params[:id])
  end

  def permitted_attributes
    params.require(:invoice).permit(%i[user_id activity_id name_override email_override rows], rows_attributes: %i[name amount price])
  end
end
