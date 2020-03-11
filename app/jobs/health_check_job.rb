class HealthCheckJob < ApplicationJob
  queue_as :default

  def perform(health_check)
    uuid = Rails.application.config.x.healthcheck_ids&.fetch(health_check.to_sym)

    return unless uuid

    HTTP.get("https://hc-ping.com/#{uuid}")
  end
end
