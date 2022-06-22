class CallbacksController < Devise::OmniauthCallbacksController
  def amber_oauth2
    user = User.from_omniauth(request.env['omniauth.auth'])

    if user.persisted?
      sign_in(:user, user)
      redirect_to user.roles.any? ? root_path : user_path(user.id)
    else
      redirect_to root_path, flash: { error: 'Authentication failed' }
    end
  end
end
