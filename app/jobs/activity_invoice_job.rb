class ActivityInvoiceJob < ApplicationJob
  queue_as :default

  def perform(activity)
    activity.manually_added_users_with_orders.each do |user|
      Invoice.create(activity: activity, user: user)
    end
  end
end
