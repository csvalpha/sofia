class UsersController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized

  def index
    @users = User.all.order(:name)
    authorize @users

    @users_credits = User.calculate_credits

    @users_json = @users.as_json
                        .each { |u| u['credit'] = @users_credits.fetch(u['id'], 0) }
                        .to_json(only: %w[id name credit])

    @new_user = User.new
  end

  def show
    @user = User.includes(:credit_mutations, roles_users: :role).find(params[:id])
    authorize @user

    @user_json = @user.to_json(only: %i[id name])
    @new_mutation = CreditMutation.new(user: @user)
  end

  def create
    @user = User.new(permitted_attributes)
    authorize @user

    if @user.save
      flash[:success] = 'Successfully created user'
    else
      flash[:error] = @user.errors.full_messages.join(', ')
    end

    redirect_to users_path
  end

  def refresh_user_list
    authorize User

    users_json.each do |user_json|
      find_or_create_user(user_json)
    end

    send_slack_users_refresh_notification

    redirect_to users_path
  end

  def search
    authorize User

    @users = User.where('lower(name) LIKE ?', "%#{params[:query]&.downcase}%")

    render json: @users
  end

  def api_token # rubocop:disable Metrics/AbcSize
    return @token if @token

    options = { grant_type: 'client_credentials',
                client_id: Rails.application.credentials.dig(Rails.env.to_sym, :banana_client_id),
                client_secret: Rails.application.credentials.dig(Rails.env.to_sym, :banana_client_secret) }
    token_response = RestClient.post "#{Rails.application.config.x.banana_api_host}/api/v1/oauth/token", options

    @token = JSON.parse(token_response)['access_token']
  end

  private

  def send_slack_users_refresh_notification
    return unless Rails.env.production? || Rails.env.staging?

    # :nocov:
    SlackMessageJob.perform_later("User ##{current_user.id} (#{current_user.name}) "\
      "is importing users from Banana (#{Rails.application.config.x.banana_api_host})}")
    # :nocov:
  end

  def users_json
    JSON.parse(RestClient.get("#{Rails.application.config.x.banana_api_host}/api/v1/users?filter[group]=Leden",
                              'Authorization' => "Bearer #{api_token}"))['data']
  end

  def find_or_create_user(user_json)
    fields = user_json['attributes']
    u = User.find_or_initialize_by(uid: user_json['id'])
    u.name = User.full_name_from_attributes(fields['first_name'],
                                            fields['last_name_prefix'],
                                            fields['last_name'])
    u.provider = 'banana_oauth2'
    u.avatar_thumb_url = fields['avatar_thumb_url']
    u.email = fields['email']
    u.birthday = fields['birthday']
    u.save
  end

  def permitted_attributes
    params.require(:user).permit(%w[name email])
  end
end
