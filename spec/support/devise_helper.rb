module DeviseHelper
  def signed_in?(user)
    user == signed_in_user
  end

  def signed_in_user
    user_session_info = response.request.env['rack.session']['warden.user.user.key']
    return unless user_session_info

    user_id = user_session_info[0][0]
    User.find(user_id)
  end
end
