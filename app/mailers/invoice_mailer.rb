class InvoiceMailer < ApplicationMailer
  def invoice_mail(invoice, to)
    @user = invoice.user
    @invoice = invoice
    @cab_disabled = true

    mail to: to, subject: "Factuur #{invoice.human_id} Stichting Sociëteit Flux"
  end
end
