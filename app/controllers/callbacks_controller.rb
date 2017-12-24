class CallbacksController < Devise::OmniauthCallbacksController
  def banana_oauth2 # rubocop:disable Metrics/AbcSize
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in(:user, @user)
      redirect_to root_path, flash: { success: 'Authenticated with C.S.V. Alpha' } if @user&.roles&.any?
      redirect_to @user, flash: { success: 'Authenticated with C.S.V. Alpha' } unless @user&.roles&.any?
    else
      redirect_to root_path, flash: { error: 'Authentication failed' }
    end
  end
end
