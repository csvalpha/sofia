class UsersController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized

  def index
    @model = User.all.includes(model_includes).order(:name)
    authorize @model

    @new_user = User.new
  end

  def show
    @user = User.includes(activities: [orders: [order_rows: :product]]).find(params[:id])
    authorize @user

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
    redirect_to users_path
  end

  def search
    authorize User

    @users = User.where('lower(name) LIKE ?', "%#{params[:query]&.downcase}%")

    render json: @users
  end

  def api_token
    return @token if @token
    options = { grant_type: 'client_credentials',
                client_id: Rails.application.secrets.fetch(:banana_client_id),
                client_secret: Rails.application.secrets.fetch(:banana_client_secret) }
    token_response = RestClient.post "#{Rails.application.config.x.banana_api_host}/api/v1/oauth/token", options

    @token = JSON.parse(token_response)['access_token']
  end

  def model_class
    User
  end

  def model_includes
    %i[credit_mutations order_rows]
  end

  private

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
    u.save
  end

  def permitted_attributes
    params.require(:user).permit(:name)
  end
end
