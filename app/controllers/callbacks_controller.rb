class CallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in(:user, @user)
      redirect_to root_path, flash: { success: 'Authenticated with Google' }
    else
      redirect_to root_path, flash: { error: 'Authentication failed' }
    end
  end

  def banana_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in(:user, @user)
      redirect_to root_path, flash: { success: 'Authenticated with C.S.V. Alpha' }
    else
      redirect_to root_path, flash: { error: 'Authentication failed' }
    end
  end
end
