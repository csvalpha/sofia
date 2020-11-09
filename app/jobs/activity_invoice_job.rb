class ActivityInvoiceJob < ApplicationJob
  queue_as :default

  def perform(activity)
    activity.manually_added_users_with_orders.each do |user|
      invoice = Invoice.create(activity: activity, user: user)

      InvoiceMailer.invoice_mail(invoice).deliver_now
      invoice.update(status: 'sent')
    end
  end
end
