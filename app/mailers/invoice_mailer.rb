class InvoiceMailer < ApplicationMailer
  def invoice_mail(invoice)
    @user = invoice.user
    @invoice = invoice
    @cab_disabled = true

    attachments["#{invoice.human_id}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(pdf: invoice.human_id.to_s, template: 'invoices/show.html.erb', layout: 'pdf.html.erb')
    )

    mail to: @invoice.user.email, subject: "Factuur #{invoice.human_id} Stichting Sociëteit Flux"
  end
end
