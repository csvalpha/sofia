class CallbacksController < Devise::OmniauthCallbacksController
  def banana_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in(:user, @user)
      success_redirect(@user)
    else
      redirect_to root_path, flash: { error: 'Authentication failed' }
    end
  end

  private

  def success_redirect(user)
    flash[:success] = 'Authenticated with C.S.V. Alpha'
    redirect_to root_path if user.roles.any?
    redirect_to User.find(user.id) unless user.roles.any?
  end
end
