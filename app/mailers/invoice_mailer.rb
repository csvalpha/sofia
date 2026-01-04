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

    html = render_to_string(
      template: 'invoices/show',
      formats: [:html],
      layout: 'pdf'
    )
    pdf = Grover.new(html).to_pdf
    attachments["#{invoice.human_id}.pdf"] = pdf

    mail to: @invoice.email, subject: "Factuur #{invoice.human_id} #{Rails.application.config.x.company_name}"
  end

  def invoice_paid(invoice)
    @user = Struct.new(:name).new(invoice.name)
    @invoice = invoice
    @cab_disabled = true

    mail to: @invoice.email, subject: "Betaalbevesting factuur #{invoice.human_id} #{Rails.application.config.x.company_name}"
  end
end
