# rubocop:disable Metrics/MethodLength
module Slackistrano
  class CustomMessaging < Messaging::Base
    def branch
      "<https://github.com/csvalpha/alpha-tomato/tree/#{fetch(:branch)}|\`#{fetch(:branch)}\`>"
    end

    def environment
      "tomato/#{stage}"
    end

    def deployer
      "`#{ENV['USER'] || ENV['USERNAME']}`"
    end

    def default_attachment
      {
        fields: [{
          title: 'Environment',
          value: environment,
          short: true
        }, {
          title: 'Branch',
          value: branch,
          short: true
        }],
        mrkdwn_in: %w[text pretext fields]
      }
    end

    def payload_for_updating
      {
        attachments: [
          default_attachment.merge(
            fallback: "Deployment started by #{deployer}",
            pretext: "Deployment started by #{deployer}",
            color: 'good'
          )
        ]
      }
    end

    def payload_for_reverting
      {
        attachments: [
          default_attachment.merge(
            fallback: "Rollback started by #{deployer}",
            pretext: "Rollback started by #{deployer}",
            color: 'good'
          )
        ]
      }
    end

    def payload_for_updated
      {
        attachments: [
          default_attachment.merge(
            fallback: "Deployment finished by #{deployer}",
            pretext: "Deployment finished by #{deployer}",
            color: 'good',
            fields:
              default_attachment[:fields] + [{
                title: 'Time',
                value: elapsed_time,
                short: true
              }]
          )
        ]
      }
    end

    def payload_for_reverted
      {
        attachments: [
          default_attachment.merge(
            fallback: "Rollback finished by #{deployer}",
            pretext: "Rollback finished by #{deployer}",
            color: 'good'
          )
        ]
      }
    end

    def payload_for_failed
      {
        attachments: [
          default_attachment.merge(
            fallback: "#{deploying? ? 'Deployment' : 'Rollback'} failed by #{deployer}",
            pretext: "#{deploying? ? 'Deployment' : 'Rollback'} failed by #{deployer}",
            color: 'danger'
          )
        ]
      }
    end
  end
end
