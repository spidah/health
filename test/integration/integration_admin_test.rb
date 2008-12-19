require "#{File.dirname(__FILE__)}/../test_helper"

class IntegrationAdminTest < ActionController::IntegrationTest
  def test_admin
    bob = new_session_as(:bob)
    bob.login(bob.user, bob.openid_url)
    bob.cant_access_admin_page

    spidah = new_session_as(:spidah)
    spidah.login(spidah.user, spidah.openid_url)
    spidah.should_access_admin_page
  end

  module AdminTestDSL
    attr_accessor :user, :openid_url

    def cant_access_admin_page
      get admin_path
      assert_dashboard_redirect
    end

    def should_access_admin_page
      get admin_path
      assert_success('admin/admin/index')
    end
  end

  def new_session_as(user)
    open_session do |session|
      session.extend(AdminTestDSL)
      session.user = get_user(users(user))
      session.openid_url = user_logins(user).openid_url
      yield session if block_given?
    end
  end
end
