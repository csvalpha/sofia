require 'digest'

class SofiaAccountsController < ApplicationController # rubocop:disable Metrics/ClassLength
  def omniauth_redirect_login
    redirect_to '/sofia_accounts/login'
  end

  def omniauth_redirect_register
    redirect_to :root
  end

  def create # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    user_id = params.require(:user_id)

    user = User.find_by(id: user_id)
    validate_user(user)

    sofia_account = SofiaAccount.new(permitted_attributes.merge(user_id:))
    raise normalize_error_messages(sofia_account.errors.full_messages) unless sofia_account.save

    update_user_after_creation(user, sofia_account)

    sign_in(:user, user)
    redirect_to user.roles.any? ? root_path : user_path(user.id), flash: { success: 'Account geactiveerd!' }
  rescue ActionController::ParameterMissing => e
    param_name = I18n.t("activerecord.attributes.sofia_account.#{e.param}")
    redirect_back_or_to :root, flash: { error: "Account activeren mislukt: #{param_name} is niet aanwezig." }
  rescue StandardError => e
    redirect_back_or_to :root, flash: { error: "Account activeren mislukt: #{e.message}." }
  end

  def update_password # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @sofia_account = SofiaAccount.find(params[:id])
    authorize @sofia_account

    begin
      new_attributes = params.require(:sofia_account).permit(%i[password password_confirmation])

      if !@sofia_account.authenticate(params.require(:sofia_account)[:old_password])
        raise 'het oude wachtwoord is fout of niet opgegeven'
      elsif new_attributes[:password].blank?
        # sofia_account.update(...) just does nothing instead of showing error, so we show error manually
        raise 'wachtwoord moet opgegeven zijn'
      elsif !@sofia_account.update(new_attributes)
        raise normalize_error_messages(@sofia_account.errors.full_messages)
      end

      redirect_to user_path(@sofia_account.user_id), flash: { success: 'Wachtwoord gewijzigd.' }
    rescue ActionController::ParameterMissing
      redirect_back_or_to :root, flash: { error: 'Wachtwoord wijzigen mislukt: sofia_account is niet aanwezig.' }
    rescue StandardError => e
      redirect_back_or_to :root, flash: { error: "Wachtwoord wijzigen mislukt: #{e.message}." }
    end
  end

  def enable_otp # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @sofia_account = SofiaAccount.find(params[:id])
    authorize @sofia_account

    begin
      flash_message =
        if @sofia_account.authenticate_otp(params.require(:verification_code), drift: 60)
          if @sofia_account.update(otp_enabled: true)
            { success: 'Two-factor-authenticatie aangezet!' }
          else
            Rails.logger.error("Failed to enable OTP for SofiaAccount ##{@sofia_account.id}: #{@sofia_account.errors.full_messages.join(', ')}") # rubocop:disable Layout/LineLength
            { error: 'Two-factor-authenticatie aanzetten mislukt: probeer het later opnieuw.' }
          end
        else
          { error: 'Two-factor-authenticatie aanzetten mislukt: de verificatie token is ongeldig.' }
        end

      redirect_to user_path(@sofia_account.user_id), flash: flash_message
    rescue ActionController::ParameterMissing
      redirect_back_or_to :root, flash: { error: 'Two-factor-authenticatie aanzetten mislukt: de verificatie token is niet aanwezig.' }
    rescue StandardError => e
      redirect_back_or_to :root, flash: { error: "Two-factor-authenticatie aanzetten mislukt: #{e.message}." }
    end
  end

  def disable_otp
    @sofia_account = SofiaAccount.find(params[:id])
    authorize @sofia_account

    if @sofia_account.update(otp_enabled: false)
      redirect_to user_path(@sofia_account.user_id), flash: { success: 'Two-factor-authenticatie uitgezet.' }
    else
      redirect_to user_path(@sofia_account.user_id), flash: { error: 'Two-factor-authenticatie uitzetten mislukt.' }
    end
  end

  def activate_account
    @user_id = params[:user_id]
    @activation_token = params[:activation_token]
    @user = User.find_by(id: @user_id)
    @request_email = @user&.email.nil?
    @sofia_account = SofiaAccount.new
  end

  def new_activation_link # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
    generic_message = 'Er is een activatielink verzonden als het account bestaat.'
    user = User.find_by(id: params.require(:user_id))

    if user && !user.deactivated && !user.sofia_account && user.email
      begin
        User.transaction do
          unless user.update(activation_token: SecureRandom.urlsafe_base64, activation_token_valid_till: 1.day.from_now)
            raise ActiveRecord::RecordInvalid, user
          end

          UserMailer.new_activation_link_email(user).deliver_later
        end
      rescue StandardError => e
        Rails.logger.error("Failed to send activation link for user_id=#{user.id}: #{e.message}")
      end
    end

    @message = generic_message
  rescue ActionController::ParameterMissing => e
    param_name = I18n.t("activerecord.attributes.sofia_account.#{e.param}")
    @message = "Uw kunt geen nieuwe activatielink aanvragen: #{param_name.downcase} is niet aanwezig."
  rescue StandardError => e
    Rails.logger.error("Failed to process new activation link request: #{e.message}")
    @message = generic_message
  end

  def forgot_password # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    generic_message = 'Als dit account bestaat, is er een email verstuurd.'
    sofia_account = SofiaAccount.find_by_login(params.require(:username))
    user = sofia_account&.user

    if user&.email.present?
      begin
        User.transaction do
          unless user.update(activation_token: SecureRandom.urlsafe_base64, activation_token_valid_till: 1.day.from_now)
            raise ActiveRecord::RecordInvalid, user
          end

          UserMailer.forgot_password_email(user).deliver_later
        end
      rescue StandardError => e
        Rails.logger.error("Failed to process forgot password for user_id=#{user.id}: #{e.message}")
      end
    end

    redirect_to :root, flash: { success: generic_message }
  rescue ActionController::ParameterMissing => e
    param_name = I18n.t("activerecord.attributes.sofia_account.#{e.param}")
    redirect_back_or_to forgot_password_view_sofia_accounts_path,
                        flash: { error: "Wachtwoord reset aanvragen mislukt: #{param_name.downcase} is niet aanwezig." }
  rescue StandardError => e
    Rails.logger.error("Failed to handle forgot password request: #{e.message}")
    redirect_back_or_to forgot_password_view_sofia_accounts_path,
                        flash: { error: 'Wachtwoord reset aanvragen mislukt.' }
  end

  def reset_password_view
    @activation_token = params[:activation_token]
    @sofia_account = SofiaAccount.find_by(id: params.require(:id))
    raise 'uw account bestaat niet' unless @sofia_account
  rescue ActionController::ParameterMissing => e
    param_name = I18n.t("activerecord.attributes.sofia_account.#{e.param}")
    redirect_back_or_to :root, flash: { error: "Wachtwoord resetten mislukt: #{param_name.downcase} is niet aanwezig." }
  rescue StandardError => e
    redirect_back_or_to :root, flash: { error: "Wachtwoord resetten mislukt: #{e.message}." }
  end

  def reset_password # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    sofia_account = SofiaAccount.find_by(id: params.require(:id))
    raise 'uw account bestaat niet' unless sofia_account

    user = sofia_account.user
    provided_token = params.require(:activation_token).to_s
    stored_token = user.activation_token.to_s
    token_missing = stored_token.blank? || provided_token.blank?
    tokens_match = !token_missing && ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(stored_token),
      ::Digest::SHA256.hexdigest(provided_token)
    )
    token_expired = user.activation_token_valid_till.try(:<, Time.zone.now)
    if token_missing || !tokens_match || token_expired
      forgot_password_url = SofiaAccount.forgot_password_url
      raise "de resetlink is verlopen of ongeldig. Een nieuwe resetlink kan worden aangevraagd via
      <a href='#{forgot_password_url}'>#{forgot_password_url}</a>"
    end

    if params.require(:sofia_account)[:password].blank?
      # sofia_account.update(...) just does nothing instead of showing error, so we show error manually
      raise 'wachtwoord moet opgegeven zijn'
    elsif !sofia_account.update(params.require(:sofia_account).permit(%i[password password_confirmation]))
      raise normalize_error_messages(sofia_account.errors.full_messages)
    end

    unless user.update(
      activation_token: nil,
      activation_token_valid_till: nil
    )
      Rails.logger.error("Failed to clear activation token for user ##{user.id}: #{user.errors.full_messages.join(', ')}")
      raise normalize_error_messages(user.errors.full_messages)
    end

    redirect_to login_sofia_accounts_path, flash: { success: 'Wachtwoord ingesteld!' }
  rescue ActionController::ParameterMissing => e
    param_name = I18n.t("activerecord.attributes.sofia_account.#{e.param}")
    redirect_back_or_to :root, flash: { error: "Wachtwoord resetten mislukt: #{param_name.downcase} is niet aanwezig." }
  rescue StandardError => e
    redirect_back_or_to :root, flash: { error: "Wachtwoord resetten mislukt: #{e.message}." }
  end

  def login
    return unless current_user

    redirect_to current_user.roles.any? ? root_path : user_path(current_user.id)
  end

  private

  def validate_user(user) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    if !user
      raise 'uw account bestaat niet'
    elsif user.deactivated
      raise 'uw account is gedeactiveerd'
    elsif user.sofia_account
      raise 'uw account is al geactiveerd'
    end

    provided_token = params.require(:activation_token).to_s
    stored_token = user.activation_token.to_s
    token_missing = stored_token.blank? || provided_token.blank?
    tokens_match = !token_missing && ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(stored_token),
      ::Digest::SHA256.hexdigest(provided_token)
    )
    token_expired = user.activation_token_valid_till.try(:<, Time.zone.now)
    return unless token_missing || !tokens_match || token_expired

    new_activation_link_url = SofiaAccount.new_activation_link_url(user.id)
    raise "de activatielink is verlopen of ongeldig. Een nieuwe activatielink kan worden aangevraagd via
             <a href='#{new_activation_link_url}'>#{new_activation_link_url}</a>"
  end

  def update_user_after_creation(user, sofia_account) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    user.reload
    user.activation_token = nil
    user.activation_token_valid_till = nil
    if params[:user] && params[:user][:email]
      if user.email # should not happen as the form only shows the email field when the user has no email
        sofia_account.destroy
        raise 'u heeft al een e-mailadres, dus u moet dat veld leeg laten'
      end
      user.email = params[:user][:email]
    end
    return if user.save

    sofia_account.destroy
    raise normalize_error_messages(user.errors.full_messages)
  end

  def permitted_attributes
    params.require(:sofia_account).permit(%i[username password password_confirmation])
  end
end
