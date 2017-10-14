# See https://gist.github.com/cannikin/2fc8134491943c04814b

namespace :sentry do
  task :notify_deployment do
    run_locally do
      require 'uri'
      require 'net/https'

      puts 'Notifying Sentry of release...'
      uri = URI.parse(fetch(:sentry_api_endpoint))
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      path = "/api/0/projects/#{fetch(:sentry_organization)}/#{fetch(:sentry_project)}/releases/"
      req = Net::HTTP::Post.new(
        path,
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{fetch(:sentry_api_auth_token)}"
      )
      req.body = %({"version":"#{fetch(:release_timestamp)}","ref":"#{fetch(:current_revision)}"})

      response = http.start { |h| h.request(req) }
      puts "Sentry response: #{response.body}"
    end
  end
end
