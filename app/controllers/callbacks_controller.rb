class CallbacksController < Devise::OmniauthCallbacksController
  def amber_oauth2
    user = User.from_omniauth(request.env['omniauth.auth'])

    if user.persisted?
      sign_in(:user, user)
      redirect_to user.roles.any? ? root_path : user_path(user.id)
    else
      redirect_to root_path, flash: { error: 'Inloggen gefaald.' }
    end
  end

  def identity
    user = User.from_omniauth_inspect(request.env['omniauth.auth'])
    
    if user.persisted?
      sofia_account = SofiaAccount.find_by(user_id: user.id)
      if user.deactivated
        render(json: { state: "password_prompt", error_message: "Uw account is gedeactiveerd, dus inloggen is niet mogelijk." })
      elsif sofia_account && sofia_account.otp_enabled
        one_time_password = params[:verification_code]
        if !one_time_password
          # OTP code not present, so request it
          render(json: { state: "otp_prompt" })
        elsif sofia_account.authenticate_otp(one_time_password)
          # OTP code correct
          sign_in(:user, user)
          render(json: { state: "logged_in", redirect_url: user.roles.any? ? root_path : user_path(user.id) })
        else
          # OTP code incorrect
          render(json: { state: "otp_prompt", error_message: "Inloggen mislukt. De authenticatiecode is incorrect." })
        end
      elsif sofia_account
        # no OTP enabled
        sign_in(:user, user)
        render(json: { state: "logged_in", redirect_url: user.roles.any? ? root_path : user_path(user.id) })
      else
        # sofia_account does not exist, should not be possible
        render(json: { state: "password_prompt", error_message: "Inloggen mislukt door een error. Herlaad de pagina en probeer het nog een keer. <br/><i>Werkt het na een paar keer proberen nog steeds niet? Neem dan contact op met de ICT-commissie.</i>" })
      end
    else
      render(json: { state: "password_prompt", error_message: "Inloggen mislukt. De ingevulde gegevens zijn incorrect." })
    end
  end

  def failure
    error_message = "Inloggen mislukt."
    if request.env['omniauth.error.strategy'].instance_of? OmniAuth::Strategies::Identity
      if request.env['omniauth.error.type'].to_s == "invalid_credentials"
        error_message << " De ingevulde gegevens zijn incorrect."
      else
        error_message << " #{request.env['omniauth.error.type'].to_s}"
      end
      render(json: { state: "password_prompt", error_message: error_message })
    else
      render(json: { state: "password_prompt", error_message: error_message })
    end
  end
end
