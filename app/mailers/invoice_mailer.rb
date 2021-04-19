class InvoiceMailer < ApplicationMailer
  def invoice_mail(invoice)
    @user = OpenStruct.new(name: invoice.name)
    @invoice = invoice
    @cab_link = url_for(controller: 'invoices', action: 'show', id: invoice.token)
    @cab_text = 'iDeal betaling'

    attachments["#{invoice.human_id}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(pdf: invoice.human_id.to_s, template: 'invoices/show.html.erb', layout: 'pdf.html.erb')
    )

    mail to: @invoice.email, subject: "Factuur #{invoice.human_id} Stichting Sociëteit Flux"
  end

  def invoice_paid(invoice)
    @user = OpenStruct.new(name: invoice.name)
    @invoice = invoice
    @cab_disabled = true

    mail to: @invoice.email, subject: "Betaalbevesting factuur #{invoice.human_id} Stichting Sociëteit Flux"
  end
end
