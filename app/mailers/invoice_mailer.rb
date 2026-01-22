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

    begin
      # Use token-based URL for unauthenticated Grover access
      url = url_for(controller: 'invoices', action: 'show', id: invoice.token, pdf: true, only_path: false)
      pdf = Grover.new(url).to_pdf
      attachments["#{invoice.human_id}.pdf"] = pdf
    rescue StandardError => e
      Rails.logger.error "Failed to generate PDF attachment for invoice #{invoice.id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      # Continue sending email without PDF attachment
    end

    mail to: @invoice.email, subject: "Factuur #{invoice.human_id} #{Rails.application.config.x.company_name}"
  end

  def invoice_paid(invoice)
    @user = Struct.new(:name).new(invoice.name)
    @invoice = invoice
    @cab_disabled = true

    mail to: @invoice.email, subject: "Betaalbevesting factuur #{invoice.human_id} #{Rails.application.config.x.company_name}"
  end
end
