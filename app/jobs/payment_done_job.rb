class PaymentDoneJob < ApplicationJob
  queue_as :default

  def perform(payment)
    if payment.user
      process_user(payment)
    end
    if payment.invoice
      process_invoice(payment)
    end

    payment.update(status: 'paid')
  end

  private

  def process_user(payment)
    mutation = CreditMutation.create(user: payment.user,
                                     amount: payment.amount,
                                     description: 'iDEAL inleg', created_by: payment.user)

    UserCreditMailer.new_credit_mutation_mail(mutation).deliver_later
  end

  def process_invoice(payment)
    CreditMutation.create(user: payment.invoice.user,
                                     amount: payment.amount,
                                     description: "Betaling factuur #{payment.invoice.human_id}", created_by: payment.user)

    InvoiceMailer.invoice_paid(payment.invoice).deliver_now
    payment.invoice.update(status: 'paid')
  end
end
