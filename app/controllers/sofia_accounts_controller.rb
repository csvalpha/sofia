class SofiaAccountsController < ApplicationController
  def omniauth_redirect_login
    redirect_to '/sofia_accounts/login'
  end

  def omniauth_redirect_register
    redirect_to :root
  end

  def create
    user_id = params.require(:user_id)

    user = User.find_by(id: user_id)
    if !user
      raise 'uw account bestaat niet'
    elsif user.deactivated
      raise 'uw account is gedeactiveerd'
    elsif user.sofia_account
      raise 'uw account is al geactiveerd'
    end

    activation_token = params.require(:activation_token)
    if user.activation_token != activation_token || user.activation_token_valid_till.try(:<, Time.zone.now)
      new_activation_link_url = SofiaAccount.new_activation_link_url(user.id)
      raise "de activatielink is verlopen of ongeldig. Een nieuwe activatielink kan worden aangevraagd via <a href='#{new_activation_link_url}'>#{new_activation_link_url}</a>"
    end

    sofia_account = SofiaAccount.new(permitted_attributes.merge(user_id: user_id))
    raise normalize_error_messages(sofia_account.errors.full_messages) unless sofia_account.save

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
    unless user.save
      sofia_account.destroy
      raise normalize_error_messages(user.errors.full_messages)
    end

    sign_in(:user, user)
    redirect_to user.roles.any? ? root_path : user_path(user.id), flash: { success: 'Account geactiveerd!' }
  rescue ActionController::ParameterMissing => e
    param_name = I18n.t("activerecord.attributes.sofia_account.#{e.param}")
    redirect_back_or_to :root, flash: { error: "Account activeren mislukt: #{param_name.downcase} is niet aanwezig." }
  rescue StandardError => e
    redirect_back_or_to :root, flash: { error: "Account activeren mislukt: #{e.message}." }
  end

  def update_password
    @sofia_account = SofiaAccount.find(params[:id])
    authorize @sofia_account

    begin
      new_attributes = params.require(:sofia_account).permit(%i[password password_confirmation])

      if !@sofia_account.authenticate(params.require(:sofia_account)[:old_password])
        raise 'het oude wachtwoord is fout of niet opgegeven'
      elsif new_attributes[:password].blank? # sofia_account.update(...) just does nothing instead of showing error, so we show error manually
        raise 'wachtwoord moet opgegeven zijn'
      elsif !@sofia_account.update(new_attributes)
        raise normalize_error_messages(@sofia_account.errors.full_messages)
      end

      redirect_to user_path(@sofia_account.user_id), flash: { success: 'Wachtwoord gewijzigd.' }
    rescue ActionController::ParameterMissing => e
      redirect_back_or_to :root, flash: { error: 'Wachtwoord wijzigen mislukt: sofia_account is niet aanwezig.' }
    rescue StandardError => e
      redirect_back_or_to :root, flash: { error: "Wachtwoord wijzigen mislukt: #{e.message}." }
    end
  end

  def enable_otp
    @sofia_account = SofiaAccount.find(params[:id])
    authorize @sofia_account

    begin
      if @sofia_account.authenticate_otp(params.require(:verification_code))
        @sofia_account.update(otp_enabled: true)
        flash[:success] = 'Two-factor-authenticatie aangezet!'
      else
        flash[:error] = 'Two-factor-authenticatie aanzetten mislukt: de verificatie token is ongeldig.'
      end

      redirect_to user_path(@sofia_account.user_id)
    rescue ActionController::ParameterMissing => e
      redirect_back_or_to :root, flash: { error: 'Two-factor-authenticatie aanzetten mislukt: de verificatie token is niet aanwezig.' }
    rescue StandardError => e
      redirect_back_or_to :root, flash: { error: "Two-factor-authenticatie aanzetten mislukt: #{e.message}." }
    end
  end

  def disable_otp
    @sofia_account = SofiaAccount.find(params[:id])
    authorize @sofia_account

    @sofia_account.update(otp_enabled: false)

    redirect_to user_path(@sofia_account.user_id)
  end

  def activate_account
    @user_id = params[:user_id]
    @activation_token = params[:activation_token]
    @user = User.find_by(id: @user_id)
    @request_email = @user&.email.nil?
    @sofia_account = SofiaAccount.new
  end

  def new_activation_link
    user = User.find_by(id: params.require(:user_id))
    if !user
      raise 'uw account bestaat niet'
    elsif user.deactivated
      raise 'uw account is gedeactiveerd'
    elsif user.sofia_account
      raise 'uw account is al geactiveerd'
    elsif !user.email
      raise 'uw account heeft geen emailadres'
    end

    user.update(activation_token: SecureRandom.urlsafe_base64, activation_token_valid_till: 1.day.from_now)
    UserMailer.new_activation_link_email(user).deliver_later
    @message = 'Er is een nieuwe activatielink voor uw account verstuurd naar uw emailadres.'
  rescue ActionController::ParameterMissing => e
    param_name = I18n.t("activerecord.attributes.sofia_account.#{e.param}")
    @message = "Uw kunt geen nieuwe activatielink aanvragen: #{param_name.downcase} is niet aanwezig."
  rescue StandardError => e
    @message = "Uw kunt geen nieuwe activatielink aanvragen: #{e.message}."
  end

  def forgot_password
    sofia_account = SofiaAccount.find_by(username: params.require(:username))
    raise 'gebruikersnaam bestaat niet' unless sofia_account

    raise 'uw account heeft geen emailadres' unless sofia_account.user.email

    sofia_account.user.update(activation_token: SecureRandom.urlsafe_base64, activation_token_valid_till: 1.day.from_now)
    UserMailer.forgot_password_email(sofia_account.user).deliver_later
    redirect_to :root, flash: { success: 'Een link om uw wachtwoord te resetten is verstuurd naar uw emailadres.' }
  rescue ActionController::ParameterMissing => e
    param_name = I18n.t("activerecord.attributes.sofia_account.#{e.param}")
    redirect_back_or_to forgot_password_view_sofia_accounts_path,
                        flash: { error: "Wachtwoord reset aanvragen mislukt: #{param_name.downcase} is niet aanwezig." }
  rescue StandardError => e
    redirect_back_or_to forgot_password_view_sofia_accounts_path, flash: { error: "Wachtwoord reset aanvragen mislukt: #{e.message}." }
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

  def reset_password
    sofia_account = SofiaAccount.find_by(id: params.require(:id))
    raise 'uw account bestaat niet' unless sofia_account

    user = sofia_account.user
    activation_token = params.require(:activation_token)
    if user.activation_token != activation_token || user.activation_token_valid_till.try(:<, Time.zone.now)
      forgot_password_url = SofiaAccount.forgot_password_url
      raise "de resetlink is verlopen of ongeldig. Een nieuwe resetlink kan worden aangevraagd via <a href='#{forgot_password_url}'>#{forgot_password_url}</a>"
    end

    if params.require(:sofia_account)[:password].blank? # sofia_account.update(...) just does nothing instead of showing error, so we show error manually
      raise 'wachtwoord moet opgegeven zijn'
    elsif !sofia_account.update(params.require(:sofia_account).permit(%i[password password_confirmation]))
      raise normalize_error_messages(sofia_account.errors.full_messages)
    end

    user.update(
      activation_token: nil,
      activation_token_valid_till: nil
    )
    redirect_to login_sofia_accounts_path, flash: { success: 'Wachtwoord ingesteld!' }
  rescue ActionController::ParameterMissing => e
    param_name = I18n.t("activerecord.attributes.sofia_account.#{e.param}")
    redirect_back_or_to :root, flash: { error: "Wachtwoord resetten mislukt: #{param_name.downcase} is niet aanwezig." }
  rescue StandardError => e
    redirect_back_or_to :root, flash: { error: "Wachtwoord resetten mislukt: #{e.message}." }
  end

  def login
    if current_user
      redirect_to current_user.roles.any? ? root_path : user_path(current_user.id)
    end
  end

  private

  def permitted_attributes
    params.require(:sofia_account).permit(%i[username password password_confirmation])
  end
end
