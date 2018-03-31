class SlackMessageJob < ApplicationJob
  include SlackHelper
  queue_as :default

  def perform(message)
    ping(message)
  end
end
