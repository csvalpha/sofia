class CallbacksController < Devise::OmniauthCallbacksController
  def banana_oauth2 # rubocop:disable Metrics/AbcSize
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in(:user, @user)
      redirect_to root_path, flash: { success: 'Authenticated with C.S.V. Alpha' } if @user&.roles&.any?
      redirect_to_user(@user) unless @user&.roles&.any?
    else
      redirect_to root_path, flash: { error: 'Authentication failed' }
    end
  end

  private

  def redirect_to_user(user)
    new_user = User.find(user.id)
    redirect_to new_user, flash: { success: 'Authenticated with C.S.V. Alpha' }
  end
end
