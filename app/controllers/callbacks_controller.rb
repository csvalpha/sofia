class CallbacksController < Devise::OmniauthCallbacksController
  def amber_oauth2
    user = User.from_omniauth(request.env['omniauth.auth'])

    if user&.persisted?
      sign_in(:user, user)
      redirect_to user.roles.any? ? root_path : user_path(user.id)
    else
      redirect_to root_path, flash: { error: 'Inloggen gefaald.' }
    end
  end

  def identity
    user = User.from_omniauth_inspect(request.env['omniauth.auth'])

    if user&.persisted?
      if user.deactivated
        render json: { state: 'password_prompt', error_message: 'Uw account is gedeactiveerd, dus inloggen is niet mogelijk.' }
      else
        check_identity_with_user(user, SofiaAccount.find_by(user_id: user.id))
      end
    else
      render json: { state: 'password_prompt', error_message: 'Inloggen mislukt. De ingevulde gegevens zijn incorrect.' }
    end
  end

  def check_identity_with_user(user, sofia_account)
    if sofia_account&.otp_enabled
      check_identity_with_otp(sofia_account, user)
    elsif sofia_account
      # no OTP enabled
      sign_in(:user, user)
      render json: { state: 'logged_in', redirect_url: user.roles.any? ? root_path : user_path(user.id) }
    else
      # sofia_account does not exist, should not be possible
      render json: { state: 'password_prompt', error_message: 'Inloggen mislukt door een error. Herlaad de pagina en probeer het nog
                                                               een keer. <br/><i>Werkt het na een paar keer proberen nog steeds niet?
                                                               Neem dan contact op met de ICT-commissie.</i>' }
    end
  end

  def check_identity_with_otp(sofia_account, user)
    if params[:verification_code].blank?
      # OTP code not present, so request it
      render json: { state: 'otp_prompt' }
    elsif sofia_account.authenticate_otp(params[:verification_code], drift: 60)
      # OTP code correct
      sign_in(:user, user)
      render json: { state: 'logged_in', redirect_url: user.roles.any? ? root_path : user_path(user.id) }
    else
      # OTP code incorrect
      render json: { state: 'otp_prompt', error_message: 'Inloggen mislukt. De authenticatiecode is incorrect.' }
    end
  end

  def failure
    error_message = 'Inloggen mislukt.'
    if request.env['omniauth.error.strategy'].instance_of? OmniAuth::Strategies::Identity
      error_message << if request.env['omniauth.error.type'].to_s == 'invalid_credentials'
                         ' De ingevulde gegevens zijn incorrect.'
                       else
                         ' Er is een onverwachte fout opgetreden.'
                       end
    end
    render json: { state: 'password_prompt', error_message: }
  end
end
