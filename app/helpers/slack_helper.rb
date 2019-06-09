module SlackHelper
  delegate :ping, to: :notifier

  private

  def notifier
    # rubocop:disable Rails/HelperInstanceVariable
    @notifier ||= Slack::Notifier.new(
      Rails.application.config.x.slack_webhook,
      username: 'SOFIA',
      channel: Rails.application.config.x.slack_channel
    )
    # rubocop:enable Rails/HelperInstanceVariable
  end
end
