require "#{File.dirname(__FILE__)}/../test_helper"

class IntegrationNormalLoginTest < ActionController::IntegrationTest
  def test_user_logins
    laura = new_session
    laura.signup('laura', 'password', 'password')
    laura.logout
    laura.login('laura', 'password')

    amanda = new_session
    amanda.cant_signup_with_existing_loginname('amanda', 'password', 'password')
    amanda.cant_signup_with_existing_loginname('AmandA', 'password', 'password')
    amanda.cant_login_with_wrong_loginname('amanda2', 'wrong')
    amanda.cant_login_with_wrong_password('amanda', 'wrong')

    tiffany = new_session
    tiffany.cant_signup_with_short_password('tiffany', '1', '1')
    tiffany.cant_signup_with_short_password('tiffany', '1', '2')
    tiffany.cant_signup_with_long_password('tiffany', '12345678901234567890123456789012345678901', '12345678901234567890123456789012345678901')
    tiffany.cant_signup_with_long_password('tiffany', '12345678901234567890123456789012345678901', '12345678901234567890123456789012345678900')
    tiffany.cant_signup_with_no_password('tiffany', '', '')
    tiffany.cant_signup_without_password_confirmation('tiffany', '1111', '')
    tiffany.cant_signup_with_wrong_password_confirmation('tiffany', '1111', '2222')
  end

  module UserLoginsTestDSL
    attr_accessor :user

    def assert_signup_form
      assert_select "form[id=signup_form]" do
        assert_select "input[id=loginname][name='loginname'][type=text]", 1
        assert_select "input[id=password][name='password'][type=password]", 1
        assert_select "input[id=password_confirmation][name='password_confirmation'][type=password]", 1
      end
    end

    def assert_login_form
      assert_select "form[id=normal_login_form]" do
        assert_select "input[id=loginname][name='loginname'][type=text]", 1
        assert_select "input[id=password][name='password'][type=password]", 1
      end
    end

    def signup(loginname, password, password_confirmation)
      get signup_path
      assert_signup_form

      post signup_path, {:loginname => loginname, :password => password, :password_confirmation => password_confirmation}
      assert_and_follow_redirect(edit_user_path, 'users/edit')
      assert_no_flash('error')
    end

    def invalid_signup(loginname, password, password_confirmation)
      post signup_path, {:loginname => loginname, :password => password, :password_confirmation => password_confirmation}
      assert_success('sessions/signup')
      assert_flash('error', nil, 'Signup error')
    end

    def cant_signup_with_existing_loginname(loginname, password, password_confirmation)
      invalid_signup(loginname, password, password_confirmation)
      assert_flash_item('error', 'That login name is already taken. Please select another one.')
    end

    def cant_signup_with_short_password(loginname, password, password_confirmation)
      invalid_signup(loginname, password, password_confirmation)
      assert_flash_item('error', 'Please pick a password between 4 and 40 characters long.')
    end

    def cant_signup_with_long_password(loginname, password, password_confirmation)
      invalid_signup(loginname, password, password_confirmation)
      assert_flash_item('error', 'Please pick a password between 4 and 40 characters long.')
    end

    def cant_signup_with_no_password(loginname, password, password_confirmation)
      invalid_signup(loginname, password, password_confirmation)
      assert_flash_item('error', 'Please enter a password.')
    end

    def cant_signup_without_password_confirmation(loginname, password, password_confirmation)
      invalid_signup(loginname, password, password_confirmation)
      assert_flash_item('error', 'Please confirm your password correctly.')
    end

    def cant_signup_with_wrong_password_confirmation(loginname, password, password_confirmation)
      invalid_signup(loginname, password, '')
      assert_flash_item('error', 'Please confirm your password correctly.')
    end

    def login(loginname, password)
      get login_path
      assert_login_form

      post session_path, {:loginname => loginname, :password => password}
      assert_dashboard_redirect
      assert_no_flash('error')
    end

    def cant_login_with_wrong_loginname(loginname, password)
      post session_path, {:loginname => loginname, :password => password}
      assert_and_follow_redirect(login_path, 'sessions/new')
      assert_flash('error', 'Unable to log you in. Please check your loginname and password and try again.', 'Login error')
    end

    def cant_login_with_wrong_password(loginname, password)
      post session_path, {:loginname => loginname, :password => password}
      assert_and_follow_redirect(login_path, 'sessions/new')
      assert_flash('error', 'Unable to log you in. Please check your loginname and password and try again.', 'Login error')
    end

    def logout
      delete logout_path
    end
  end

  def new_session
    open_session do |session|
      session.extend(UserLoginsTestDSL)
      yield session if block_given?
    end
  end
end
