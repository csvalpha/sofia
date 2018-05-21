namespace :send_mail do
  desc 'Send credit mail notifications'
  task credit: :environment do
    CreditInsufficientNotificationJob.perform_now
  end
end
