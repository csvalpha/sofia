module SlackHelper
  delegate :ping, to: :notifier

  private

  def notifier
    @notifier ||= Slack::Notifier.new(
      Rails.application.credentials.slack_webhook,
      username: 'Sofia',
      channel: Rails.application.config.x.slack_channel
    )
  end
end
