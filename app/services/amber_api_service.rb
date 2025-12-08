class AmberApiService
  def initialize
    @token = nil
  end

  # Get OAuth token from Amber API
  def access_token
    return @token if @token.present?

    options = {
      grant_type: 'client_credentials',
      client_id: Rails.application.config.x.amber_client_id,
      client_secret: Rails.application.config.x.amber_client_secret
    }

    response = RestClient.post("#{api_url}/api/v1/oauth/token", options)
    @token = JSON.parse(response)['access_token']
  end

  # Fetch users from Amber API
  def fetch_users
    response = RestClient.get(
      "#{api_url}/api/v1/users?filter[group]=Leden",
      'Authorization' => "Bearer #{access_token}"
    )
    JSON.parse(response)['data']
  end

  private

  def api_url
    Rails.application.config.x.amber_api_url
  end
end
