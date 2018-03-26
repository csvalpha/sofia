module SlackHelper
  delegate :ping, to: :notifier

  private

  def notifier
    @notifier ||= Slack::Notifier.new(
      Rails.application.secrets.fetch(:slack_webhook),
      username: 'Tomato',
      channel: Rails.application.config.x.slack_channel
    )
  end
end
