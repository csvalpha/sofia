class InvoiceMailer < ApplicationMailer
  def invoice_mail(invoice) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @user = Struct.new(:name).new(invoice.name)
    @invoice = invoice
    if Rails.application.config.x.mollie_api_key.present?
      @cab_link = url_for(controller: 'invoices', action: 'show', id: invoice.token)
      @cab_text = 'iDeal betaling'
    else
      @cab_disabled = true
    end

    attachments["#{invoice.human_id}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(pdf: invoice.human_id.to_s, template: 'invoices/show', layout: 'pdf')
    )

    mail to: @invoice.email, subject: "Factuur #{invoice.human_id} #{Rails.application.config.x.company_name}"
  end

  def invoice_paid(invoice)
    @user = Struct.new(:name).new(invoice.name)
    @invoice = invoice
    @cab_disabled = true

    mail to: @invoice.email, subject: "Betaalbevesting factuur #{invoice.human_id} #{Rails.application.config.x.company_name}"
  end
end
