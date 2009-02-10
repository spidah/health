require "#{File.dirname(__FILE__)}/../test_helper"

class IntegrationOpenidLoginTest < ActionController::IntegrationTest
  def test_openid_links
    newbie1 = new_session
    newbie1.login_new_openid('http://newbie1.myopenid.com/', 'newbie1', 'newbie1@gmail.com', 'm', Date.new(1982, 8, 16), 'London')
    newbie1.signup('newbie1', 'apassword')
    newbie1.logout
    newbie1.login_existing_openid('http://newbie1.myopenid.com/', 'newbie1')

    newbie2 = new_session
    newbie2.login_new_openid('http://newbie2.myopenid.com/', 'newbie2', 'newbie2@gmail.com', 'f', Date.new(1982, 8, 16), 'London')
    newbie2.cant_signup_with_existing_loginname('newbie1', 'apassword')
    newbie2.signup('newbie2', 'apassword')
    newbie2.cant_link_invalid_openid('http://failed.myopenid.com/')
    newbie2.cant_link_invalid_openid('http://missing.myopenid.com/')
    newbie2.cant_link_invalid_openid('http://cancelled.myopenid.com/')
    newbie2.cant_link_own_existing_openid('http://newbie2.myopenid.com/')
    newbie2.cant_link_someone_elses_existing_openid('http://newbie1.myopenid.com/')
    newbie2.should_link_openid('http://newbie3.myopenid.com/')
    newbie2.logout
    newbie2.login_existing_openid('http://newbie3.myopenid.com/', 'newbie2')
    newbie2.check_number_of_linked_openids(2)
    newbie2.cant_delete_someone_elses_linked_openid('http://newbie1.myopenid.com/')
    newbie2.cant_delete_invalid_openid(1000)
    newbie2.should_delete_linked_openid('http://newbie2.myopenid.com/')
    newbie2.check_number_of_linked_openids(1)
    newbie2.assert_openid_not_linked('http://newbie2.myopenid.com/')

    newbie3 = new_session
    newbie3.cant_login_bad_openid('http://failed.myopenid.com/', 'OpenID verification failed')
    newbie3.cant_login_bad_openid('http://missing.myopenid.com/', "Sorry, the OpenID server couldn't be found")
    newbie3.cant_login_bad_openid('http://cancelled.myopenid.com/', 'OpenID verification was canceled')
  end

  module OpenidLinksTestDSL
    attr_accessor :openid_url

    def assert_logged_in_as(loginname)
      assert_select('div', /Logged in as #{loginname}./)
    end

    def assert_user_data_values(gender, dob, timezone)
      assert_select("select[id=user_gender][name='user[gender]']>option[value=?][selected=selected]", gender)
      assert_select("select[id=user_dob_3i][name='user[dob(3i)]']>option[value=?][selected=selected]", dob.day)
      assert_select("select[id=user_dob_2i][name='user[dob(2i)]']>option[value=?][selected=selected]", dob.month)
      assert_select("select[id=user_dob_1i][name='user[dob(1i)]']>option[value=?][selected=selected]", dob.year)
      assert_select("select[id=user_timezone][name='user[timezone]']>option[selected=selected]", /#{timezone}/)
    end

    def assert_linked_openid(openid_url, count = 1)
      assert_select('span[class=openid-link]', {:text => openid_url, :count => count})
    end

    def assert_openid_linked(openid_url)
      get(edit_user_path)
      assert_success('users/edit')
      assert_linked_openid(openid_url)

      assert_not_nil(UserLogin.get(openid_url))
    end

    def assert_openid_not_linked(openid_url)
      get(edit_user_path)
      assert_success('users/edit')
      assert_linked_openid(openid_url, 0)
    end

    def get_openid_for_openid_url(openid_url)
      UserLogin.find(:first, :conditions => {:openid_url => normalise_url(openid_url)})
    end

    def login_new_openid(openid_url, loginname, email, gender, dob, timezone)
      self.openid_url = openid_url
      $mockuser = {:loginname => loginname, :email => email, :gender => gender, :dob => dob, :timezone => timezone}
      post(session_path, :openid_url => openid_url)
      get(open_id_complete_path, :openid_url => openid_url, :open_id_complete => 1)
      assert_and_follow_redirect(signup_path, 'sessions/signup')

      assert_select('input[type=text][name=loginname][value=?]', loginname)
    end

    def login_existing_openid(openid_url, loginname)
      self.openid_url = openid_url
      post(session_path, :openid_url => openid_url)
      get(open_id_complete_path, :openid_url => openid_url, :open_id_complete => 1)
      assert_dashboard_redirect
      assert_logged_in_as(loginname)
    end

    def cant_login_bad_openid(openid_url, message)
      post(session_path, :openid_url => openid_url)
      get(open_id_complete_path, :openid_url => openid_url, :open_id_complete => 1)
      assert_and_follow_redirect(login_path, 'sessions/new')

      assert_flash('error', nil, 'Login error')
      assert_flash_item('error', message)
    end

    def signup(loginname, password)
      post(signup_path, {:loginname => loginname, :password => password, :password_confirmation => password})
      assert_user_settings_redirect
      assert_no_flash('error')
      assert_user_data_values($mockuser[:gender], $mockuser[:dob], $mockuser[:timezone])
      assert_linked_openid(self.openid_url)
    end

    def logout
      delete(logout_path)
    end
    
    def perform_openid_link(openid_url, flash_type, flash_message)
      post(openid_links_path, :openid_link => openid_url)
      get(openid_links_path, :openid_link => openid_url, :open_id_complete => 1)

      assert_user_settings_redirect
      assert_flash(flash_type, flash_message)
    end

    def should_link_openid(openid_url)
      perform_openid_link(openid_url, 'info',
        "OpenID login #{openid_url} was successfully linked to your account. You may now login using it.")
      assert_openid_linked(openid_url)
    end

    def cant_link_invalid_openid(openid_url)
      perform_openid_link(openid_url, 'error',
        "You failed to login #{openid_url} correctly and it has not been added to the list of linked OpenID accounts.")
      assert_openid_not_linked(openid_url)
    end

    def cant_link_own_existing_openid(openid_url)
      perform_openid_link(openid_url, 'error',
        "You have already linked #{openid_url} to your account.")
    end

    def cant_link_someone_elses_existing_openid(openid_url)
      perform_openid_link(openid_url, 'error',
        "Someone has already linked #{openid_url} to their account.")
    end

    def check_number_of_linked_openids(count)
      get(edit_user_path)
      assert_success('users/edit')

      assert_select('span[class=openid-link]', count)
    end

    def should_delete_linked_openid(openid_url)
      assert_openid_linked(openid_url)

      delete(openid_link_path(get_openid_for_openid_url(openid_url)))

      assert_user_settings_redirect
      assert_flash('info', "OpenID login #{openid_url} has been unlinked.")
      assert_openid_not_linked(openid_url)
      assert_nil(UserLogin.get(openid_url))
    end

    def cant_delete_someone_elses_linked_openid(openid_url)
      assert_openid_not_linked(openid_url)
      assert(oid = UserLogin.get(openid_url))

      delete(openid_link_path(oid))

      assert_user_settings_redirect
      assert_flash('error', 'Unable to remove the link. Please go back and try again.', 'OpenID Error')

      assert(oid = UserLogin.get(openid_url))
    end
    
    def cant_delete_invalid_openid(id)
      delete(openid_link_path(id))

      assert_user_settings_redirect
      assert_flash('error', 'Unable to remove the link. Please go back and try again.', 'OpenID Error')
    end

    def cant_signup_with_existing_loginname(loginname, password)
      post(signup_path, {:loginname => loginname, :password => password, :password_confirmation => password})

      assert_success('sessions/signup')
      assert_flash('error', 'That login name is already taken. Please select another one.', 'Signup error')
    end
  end

  def new_session
    open_session do |session|
      session.extend(OpenidLinksTestDSL)
      yield session if block_given?
    end
  end
end
