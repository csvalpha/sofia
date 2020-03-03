class HealthCheckJob < ApplicationJob
  queue_as :default

  def perform(health_check)
    uuid = Rails.application.config.x.dig(:healthcheck_ids, health_check.to_sym)

    return if uuid.empty?

    Net::HTTP.get(URI.parse("https://hc-ping.com/#{uuid}"))
  end
end
