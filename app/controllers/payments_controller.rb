class PaymentsController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :authenticate_user!, only: %i[index create add setup_mandate mandate_callback toggle_auto_charge]
  after_action :verify_authorized, only: %i[index create add setup_mandate toggle_auto_charge]

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

  def setup_mandate # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    authorize :payment

    if Rails.application.config.x.mollie_api_key.blank?
      flash[:error] = 'iDEAL is niet beschikbaar'
      redirect_to user_path(current_user)
      return
    end

    begin
      # Create or retrieve Mollie customer
      mollie_customer = if current_user.mollie_customer_id.present?
                          Mollie::Customer.get(current_user.mollie_customer_id)
                        else
                          Mollie::Customer.create(
                            name: current_user.name,
                            email: current_user.email
                          )
                        end

      current_user.update(mollie_customer_id: mollie_customer.id)

      # Create payment for 1 cent to set up mandate
      payment = Payment.create_with_mollie(
        'Automatische opwaardering setup (1 cent)',
        user: current_user,
        amount: 0.01,
        first_payment: true
      )

      if payment.valid?
        checkout_url = payment.mollie_payment.checkout_url
        redirect_to URI.parse(checkout_url).to_s, allow_other_host: true
      else
        flash[:error] = "Kon betaling niet aanmaken: #{payment.errors.full_messages.join(', ')}"
        redirect_to user_path(current_user)
      end
    rescue Mollie::ResponseError => e
      flash[:error] = "Mollie fout: #{e.message}"
      redirect_to user_path(current_user)
    end
  end

  def mandate_callback # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
    payment = Payment.find(params[:id])
    unless payment
      redirect_to users_path
      return
    end

    if payment.completed?
      flash[:error] = 'Deze betaling is al verwerkt'
    else
      tries = 3
      begin
        payment.update(status: payment.mollie_payment.status)

        if payment.mollie_payment.paid?
          # Extract mandate from payment
          if payment.mollie_payment.mandate_id
            current_user.update(mollie_mandate_id: payment.mollie_payment.mandate_id)
            flash[:success] = 'Automatische opwaardering ingesteld! Je kan nu automatische opwaardering inschakelen.'
          else
            flash[:success] = 'Betaling gelukt, maar mandate kon niet worden opgeslagen.'
          end
        else
          flash[:error] = 'iDEAL betaling is mislukt. Mandate kon niet worden ingesteld.'
        end
      rescue ActiveRecord::StaleObjectError => e
        raise e unless (tries -= 1).positive?

        payment = Payment.find(params[:id])
        retry
      end
    end

    redirect_to user_path(current_user)
  end

  def toggle_auto_charge
    authorize :payment
    toggle_auto_charge_handler
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

  private

  def toggle_auto_charge_handler
    return handle_invalid_mandate unless valid_mandate?

    toggle_user_auto_charge
    redirect_to user_path(current_user)
  end

  def valid_mandate?
    current_user.mollie_mandate_id.present? && current_user.mandate_valid?
  end

  def handle_invalid_mandate
    flash[:error] = 'Je hebt geen geldige mandate ingesteld'
    redirect_to user_path(current_user)
  end

  def toggle_user_auto_charge
    current_user.update(auto_charge_enabled: !current_user.auto_charge_enabled)
    set_auto_charge_flash_message
  end

  def set_auto_charge_flash_message
    if current_user.auto_charge_enabled
      flash[:success] = 'Automatische opwaardering ingeschakeld'
    else
      flash[:warning] = 'Automatische opwaardering uitgeschakeld'
    end
  end
end
