class UsersController < ApplicationController
  before_action :set_model, only: %i[show update destroy]
  before_action :authenticate_user!

  def index
    @model = User.all.includes(model_includes)
  end

  def refresh_user_list
    available_users = []
    users_json.each do |user_json|
      available_users << find_or_create_user(user_json)
    end
    archive_unavailable_users(available_users)
    redirect_to users_path
  end

  def api_token
    return @token if @token
    options = { grant_type: 'client_credentials',
                client_id: Rails.application.secrets.fetch(:banana_client_id),
                client_secret: Rails.application.secrets.fetch(:banana_client_secret) }
    token_response = RestClient.post 'http://localhost:3000/oauth/token', options

    @token = JSON.parse(token_response)['access_token']
  end

  def model_class
    User
  end

  def model_includes
    [:orders, :credit_mutations, orders: :order_rows]
  end

  private

  def users_json
    JSON.parse(RestClient.get('http://localhost:3000/users',
                              'Accept' => 'application/vnd.csvalpha.nl; version=1',
                              'Authorization' => "Bearer #{api_token}"))['data']
  end

  def find_or_create_user(user_json)
    fields = user_json['attributes']
    User.find_or_create_by(uid: user_json['id']) do |u|
      u.name = [fields['first-name'], fields['last-name-prefix'],
                fields['last-name']].reject(&:blank?).join(' ')
      u.provider = 'banana_oauth2'
    end
  end

  def archive_unavailable_users(available_users)
    (User.in_banana - available_users).map(&:destroy)
  end
end
