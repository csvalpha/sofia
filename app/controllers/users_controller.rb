class UsersController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :authenticate_user!, except: %i[activate_account]

  after_action :verify_authorized, except: %i[activate_account]

  def index # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    authorize User

    @manual_users = User.manual.active.order(:name).select { |u| policy(u).show? }
    @identity_users = User.identity.active.order(:name).select { |u| policy(u).show? }
    @amber_users = User.in_amber.active.order(:name).select { |u| policy(u).show? }
    @inactive_users = User.inactive.order(:name).select { |u| policy(u).show? }
    @deactivated_users = User.deactivated.order(:name).select { |u| policy(u).show? }
    @users_credits = User.calculate_credits

    @manual_users_json = @manual_users.as_json(only: %w[id name])
                                      .each { |u| u['credit'] = @users_credits.fetch(u['id'], 0) }

    @identity_users_json = @identity_users.as_json(only: %w[id name])
                                      .each { |u| u['credit'] = @users_credits.fetch(u['id'], 0) }

    @amber_users_json = @amber_users.as_json(only: %w[id name])
                                    .each { |u| u['credit'] = @users_credits.fetch(u['id'], 0) }

    @not_activated_users_json = @not_activated_users.as_json(only: %w[id name])
                                    .each { |u| u['credit'] = @users_credits.fetch(u['id'], 0) }

    @deactivated_users_json = @deactivated_users.as_json(only: %w[id name])
                                          .each { |u| u['credit'] = @users_credits.fetch(u['id'], 0) }

    @new_user = User.new
  end

  include ActiveModel::OneTimePassword::InstanceMethodsOnActivation

  def show
    @user = User.includes(:credit_mutations, roles_users: :role).find(params[:id])
    authorize @user

    @user_json = @user.to_json(only: %i[id name deactivated])
    @new_mutation = CreditMutation.new(user: @user)

    @identity = Identity.find_by(user_id: @user.id)
    if @identity
      qr_code = RQRCode::QRCode.new(@identity.provisioning_uri(@identity.username, issuer: "Streepsysteem #{Rails.application.config.x.site_association}"))
      @svg_qr_code = qr_code.as_svg(
        color: "000",
        shape_rendering: "crispEdges",
        module_size: 10,
        standalone: true,
        use_path: true,
        viewbox: true,
        svg_attributes: {
          width: "100%",
          height: "auto",
          class: "qr-code"
        }
      )
    else
      @identity = Identity.new
    end

    @new_user = @user
  end

  def json
    @user = User.find(params[:id])
    authorize @user

    @user.current_activity = Activity.find(params[:activity_id])

    render json: @user.as_json(methods: User.orderscreen_json_includes)
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

  def update
    @user = User.find(params[:id])
    authorize @user

    if @user.update(params.require(:user).permit(%i[name email deactivated]))
      flash[:success] = 'Gebruiker geupdate'
    else
      flash[:error] = "Gebruiker updaten mislukt; #{@user.errors.full_messages.join(', ')}"
    end

    redirect_to @user
  end

  def refresh_user_list
    authorize User

    users_json.each do |user_json|
      find_or_create_user(user_json)
    end

    users_not_in_json = User.active.in_amber.where.not(uid: users_json.pluck('id')).where.not(name: 'Streepsysteem Flux')
    users_not_in_json.each(&:archive!)

    send_slack_users_refresh_notification

    redirect_to users_path
  end

  def search
    authorize User

    @users = User.active.where('lower(name) LIKE ?', "%#{params[:query]&.downcase}%")

    render json: @users
  end

  def api_token
    return @token if @token

    options = { grant_type: 'client_credentials',
                client_id: Rails.application.config.x.amber_client_id,
                client_secret: Rails.application.config.x.amber_client_secret }
    token_response = RestClient.post "#{Rails.application.config.x.amber_api_url}/api/v1/oauth/token", options

    @token = JSON.parse(token_response)['access_token']
  end

  def activities # rubocop:disable Metrics/AbcSize
    user = User.find(params.require(:id))
    authorize user

    user_orders = policy_scope(Order).orders_for(user)
    activities = Activity.select(%i[id title start_time]).joins(:orders).merge(user_orders).distinct.order(start_time: :desc, id: :desc)
    activity_totals = user_orders.joins(:order_rows).group(:activity_id).sum('product_count * price_per_product')
    activities_hash = activities.map { |a| { id: a.id, title: a.title, start_time: a.start_time, order_total: activity_totals[a.id] } }

    render json: activities_hash
  end

  def activate_account 
    user = User.find(params.require(:id))
    authorize user

    if params[:activation_token] != nil
      activation_token = params.require(:activation_token)
      unless user.activation_token == activation_token &&
            user.activation_token_valid_till.try(:>, Time.zone.now)
        return head :not_found
      end
    else
      return head :not_found
    end
    @identity = Identity.new(user: user)
  end

  def update_with_identity
    @user = User.find(params[:id])
    authorize @user

    @identity = @user.identity
    authorize @identity
    
    if @user.update(params.require(:user).permit(%i[email] + (current_user.treasurer? ? %i[name deactivated] : []), identity_attributes: %i[id username]))
      flash[:success] = 'Gegevens gewijzigd'
    else
      flash[:error] = "Gegevens wijzigen mislukt; #{@user.errors.full_messages.join(', ')}"
    end

    redirect_to @user
  end

  
  private

  def send_slack_users_refresh_notification
    return unless Rails.env.production? || Rails.env.staging? || Rails.env.luxproduction?

    # :nocov:
    SlackMessageJob.perform_later("User ##{current_user.id} (#{current_user.name}) "\
                                  "is importing users from Amber (#{Rails.application.config.x.amber_api_host})")
    # :nocov:
  end

  def users_json
    JSON.parse(RestClient.get("#{Rails.application.config.x.amber_api_url}/api/v1/users?filter[group]=Leden",
                              'Authorization' => "Bearer #{api_token}"))['data']
  end

  def find_or_create_user(user_json) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    fields = user_json['attributes']
    u = User.find_or_initialize_by(uid: user_json['id'])
    u.name = User.full_name_from_attributes(fields['first_name'],
                                            fields['last_name_prefix'],
                                            fields['last_name'],
                                            fields['nickname'])
    u.provider = 'amber_oauth2'
    u.avatar_thumb_url = fields['avatar_thumb_url']
    u.email = fields['email']
    u.birthday = fields['birthday']
    u.save
  end

  def permitted_attributes
    params.require(:user).permit(%w[name email provider])
  end
end
