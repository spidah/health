module Admin::AdminUserLoginsHelper
  def link_to_user(user_login)
    if user_login.openid_url.blank?
      link_to(h(user_login.user.loginname), admin_user_path(user_login.user_id))
    else
      h(user_login.openid_url)
    end
  end

  def display_name(user_login)
    user_login.openid_url.blank? ? user_login.user.loginname : user_login.openid_url
  end
end
