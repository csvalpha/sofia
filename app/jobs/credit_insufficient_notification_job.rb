class CreditInsufficientNotificationJob < ApplicationJob
  queue_as :default

  def perform # rubocop:disable Metrics/MethodLength
    success_count = 0
    unnotifyable_users = []

    users_with_insufficient_credit.each do |user|
      if user.email.present?
        if user.provider != 'amber_oauth2' # Amber users are notified immediately
          UserCreditMailer.insufficient_credit_mail(user).deliver_later
          success_count += 1
        end
      else
        unnotifyable_users.append user.name
      end
    end

    send_notification_delivery_reports(success_count, unnotifyable_users)
  end

  def users_with_insufficient_credit
    User.all.select { |user| user.credit.negative? }
  end

  def send_notification_delivery_reports(success_count, unnotifyable_users)
    User.treasurer.each do |treasurer|
      UserCreditMailer.credit_delivery_report_mail(
        treasurer, success_count, unnotifyable_users
      ).deliver_later
    end

    return unless Rails.env.production? || Rails.env.staging?

    SlackMessageJob.perform_later("Er is voor #{Rails.application.config.x.amber_api_host} een saldomail "\
                                  "verstuurd naar #{success_count} mensen, en #{unnotifyable_users.count} saldomail(s) kon(den) niet "\
                                  'verzonden worden door het ontbreken van een e-mail adres.')

    HealthCheckJob.perform_later('credit_insufficient')
  end
end
