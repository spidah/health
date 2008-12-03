require "#{File.dirname(__FILE__)}/../test_helper"

class IntegrationAdminTest < ActionController::IntegrationTest
  def test_admin
    bob = new_session
    bob.login_openid(user_logins(:bob).openid_url)
    bob.cant_access_admin_page

    spidah = new_session
    spidah.login_openid(user_logins(:spidah).openid_url)
    spidah.should_access_admin_page
  end

  module AdminTestDSL
    def login_openid(openid_url)
      post session_path, :openid_url => openid_url
      get open_id_complete_path, :openid_url => openid_url, :open_id_complete => 1
    end

    def cant_access_admin_page
      get admin_path
      assert_dashboard_redirect
    end

    def should_access_admin_page
      get admin_path
      assert_success('admin/admin/index')
    end
  end

  def new_session
    open_session do |session|
      session.extend(AdminTestDSL)
      yield session if block_given?
    end
  end
end
