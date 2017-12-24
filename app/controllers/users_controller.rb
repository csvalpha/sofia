class UsersController < ApplicationController

  def refresh_user_list
    authorize model_class

    users_json.each do |user_json|
      find_or_create_user(user_json)
    end
    redirect_to users_path
  end

  def api_token
    return @token if @token
    options = { grant_type: 'client_credentials',
                client_id: Rails.application.secrets.fetch(:banana_client_id),
                client_secret: Rails.application.secrets.fetch(:banana_client_secret) }
    token_response = RestClient.post "#{Rails.application.config.x.banana_api_host}/api/oauth/token", options

    @token = JSON.parse(token_response)['access_token']
  end

  private

  def model_includes
    [:orders, :credit_mutations, orders: :order_rows]
  end

  def users_json
    JSON.parse(RestClient.get("#{Rails.application.config.x.banana_api_host}/api/users",
                              'Accept' => 'application/vnd.csvalpha.nl; version=1',
                              'Authorization' => "Bearer #{api_token}"))['data']
  end

  def find_or_create_user(user_json)
    fields = user_json['attributes']
    User.find_or_create_by(uid: user_json['id']) do |u|
      u.name = User.full_name_from_attributes(fields['first-name'],
                                              fields['last-name-prefix-name'],
                                              fields['last-name'])
      u.provider = 'banana_oauth2'
    end
  end
end
