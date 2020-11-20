class PaymentsController < ApplicationController
  before_action :authenticate_user!, only: %i[index create]
  after_action :verify_authorized, only: %i[index create]

  def index
    @payments = Payment.all.order(created_at: :desc)
    authorize @payments
  end

  def create # rubocop:disable Metrics/AbcSize
    authorize :payment

    payment = Payment.create_with_mollie(user: current_user, amount: params[:payment][:amount])

    if payment.valid?
      checkout_url = payment.mollie_payment.checkout_url
      redirect_to URI.parse(checkout_url).to_s
    else
      flash[:error] = payment.errors
      redirect_to add_payments_path
    end
  end

  def add
    authorize :payment

    @user = current_user
    @payment = Payment.new

    @payment.amount = params[:resulting_credit].to_i - @user.credit if params[:resulting_credit]
  end

  def callback # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    payment = Payment.find(params[:id])
    unless payment
      redirect_to users_path
      return
    end

    if payment.completed
      flash[:error] = 'Deze betaling is al gesloten. Mocht het bedrag niet bij uw inleg staan neem dan contact op met de penningmeester.'
    else
      payment.update(status: payment.mollie_payment.status)
      if payment.mollie_payment.paid?
        CreditMutation.create(user: payment.user,
                              amount: payment.mollie_payment.amount.value,
                              description: 'iDEAL inleg', created_by: payment.user)
        flash[:success] = 'iDEAL betaling geslaagd'
      else
        flash[:error] = 'Uw iDEAL betaling is mislukt.
                          Mocht het bedrag wel van uw rekening zijn gegaan neem dan contact op met de penningmeester'
      end
    end

    redirect_to user_path(payment.user)
  end

  def invoice_callback
    payment = Payment.find(params[:id])
    authorize payment

    payment.update(status: payment.mollie_payment.status)
    if payment.mollie_payment.paid?
      CreditMutation.create(user: payment.invoice.user,
                            amount: payment.mollie_payment.amount.value,
                            description: "Betaling factuur #{payment.invoice.human_id}", created_by: payment.user)
      payment.invoice.update(status: 'paid')
      flash[:success] = 'iDEAL betaling geslaagd'
    else
      flash[:error] = 'Uw iDEAL betaling is mislukt.
                        Mocht het bedrag wel van uw rekening zijn gegaan neem dan contact op met de penningmeester'
    end

    redirect_to invoice_path(payment.invoice)
  end
end
