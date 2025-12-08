class AmberApiService
  TOKEN_CACHE_KEY = 'amber_api_access_token'
  TOKEN_EXPIRATION = 2.hours

  # Get OAuth token from Amber API
  def access_token
    Rails.cache.fetch(TOKEN_CACHE_KEY, expires_in: TOKEN_EXPIRATION) do
      fetch_new_token
    end
  end

  # Fetch users from Amber API
  def fetch_users
    begin
      response = RestClient.get(
        "#{api_url}/api/v1/users?filter[group]=Leden",
        'Authorization' => "Bearer #{access_token}"
      )
      JSON.parse(response)['data']
    rescue RestClient::ExceptionWithResponse, JSON::ParserError => e
      Rails.logger.error("Failed to fetch users from Amber API: #{e.message}")
      []
    end
  end

  private

  def fetch_new_token
    options = {
      grant_type: 'client_credentials',
      client_id: Rails.application.config.x.amber_client_id,
      client_secret: Rails.application.config.x.amber_client_secret
    }

    begin
      response = RestClient.post("#{api_url}/api/v1/oauth/token", options)
      JSON.parse(response)['access_token']
    rescue RestClient::ExceptionWithResponse, JSON::ParserError => e
      Rails.logger.error("Failed to obtain Amber API token: #{e.message}")
      nil
    end
  end

  def api_url
    Rails.application.config.x.amber_api_url
  end
end
