class PaymentsController < ApplicationController
  before_action :authenticate_user!, only: %i[index create add]
  after_action :verify_authorized, only: %i[index create add]

  def index
    @payments = Payment.order(created_at: :desc)
    authorize @payments
  end

  def create # rubocop:disable Metrics/AbcSize
    authorize :payment

    payment = Payment.create_with_mollie("#{Rails.application.config.x.site_short_name} zatladder saldo inleg",
                                         user: current_user, amount: params[:payment][:amount])

    if payment.valid?
      checkout_url = payment.mollie_payment.checkout_url
      redirect_to URI.parse(checkout_url).to_s, allow_other_host: true
    else
      flash[:error] = payment.errors
      redirect_to add_payments_path
    end
  end

  def add # rubocop:disable Metrics/AbcSize
    authorize :payment

    if Rails.application.config.x.mollie_api_key.blank?
      flash[:error] = 'iDEAL is niet beschikbaar'
      redirect_to users_path
      return
    end

    @user = current_user
    @payment = Payment.new

    @payment.amount = params[:resulting_credit].to_f - @user.credit if params[:resulting_credit]
  end

  def callback # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
    payment = Payment.find(params[:id])
    unless payment
      redirect_to users_path
      return
    end

    if payment.completed?
      flash[:error] =
        "Deze betaling is al gesloten. Mocht het bedrag niet bij uw inleg staan
          neem dan contact op met de #{Rails.application.config.x.treasurer_title}"
    else
      tries = 3
      begin
        payment.update(status: payment.mollie_payment.status)
        if payment.mollie_payment.paid?
          flash[:success] = 'iDEAL betaling geslaagd'
        else
          flash[:error] = "Uw iDEAL betaling is mislukt. Mocht het bedrag wel van uw rekening zijn gegaan
                            neem dan contact op met de #{Rails.application.config.x.treasurer_title}"
        end
      rescue ActiveRecord::StaleObjectError => e
        raise e unless (tries -= 1).positive?

        # Refresh object from database
        payment = Payment.find(params[:id])
        retry
      end
    end

    if payment.user
      redirect_to user_path(payment.user)
    else
      redirect_to invoice_path(payment.invoice.token)
    end
  end
end
