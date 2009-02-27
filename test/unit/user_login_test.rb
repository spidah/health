require File.dirname(__FILE__) + '/../test_helper'

class UserLoginTest < Test::Unit::TestCase
  def test_should_create_user_logins
    assert_difference UserLogin, :count do
      user_logins = create_user_login
      assert !user_logins.new_record?, "#{user_logins.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_password
    assert_no_difference UserLogin, :count do
      u = create_user_login(:password => '')
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference UserLogin, :count do
      u = create_user_login(:password_confirmation => '')
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_reset_password
    amanda = UserLogin.authenticate(users(:amanda).id, 'test')
    amanda.password = 'new password'
    amanda.password_confirmation = 'new password'
    amanda.save
    assert_equal amanda, UserLogin.authenticate(users(:amanda).id, 'new password')
  end

  def test_should_authenticate_user_logins
    assert_equal user_logins(:amanda), UserLogin.authenticate(users(:amanda).id, 'test')
  end

  def test_should_fail_on_short_password
    assert_no_difference UserLogin, :count do
      pswd = '1'
      u = create_user_login(:password => pswd, :password_confirmation => pswd)
      assert u.errors.on(:password)
    end
  end

  def test_should_fail_on_long_password
    assert_no_difference UserLogin, :count do
      pswd = '12345678901234567890123456789012345678901'
      u = create_user_login(:password => pswd, :password_confirmation => pswd)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_valid_password
    amanda = create_user_login(:user_id => users(:amanda).id)
    assert_equal nil, UserLogin.authenticate(users(:amanda).id, 'randomfalsepassword')
  end

  def test_should_return_admin_pagination
    user_logins = UserLogin.admin_pagination(1)
    assert user_logins
    assert_equal 4, user_logins.size

    (1..20).each { |i|
      u = User.create(:loginname => "newuser#{i}", :email => "spidahman#{i}@gmail.com", :gender => 'm', :dob => Date.today,
        :timezone => 0, :weight_units => 'lbs', :measurement_units => 'inches')
      create_user_login(:password => 'test', :password_confirmation => 'test', :user_id => u.id)
    }

    user_logins = UserLogin.admin_pagination(1)
    assert user_logins
    assert_equal 20, user_logins.size

    user_logins = UserLogin.admin_pagination(2)
    assert user_logins
    assert_equal 4, user_logins.size
  end

  protected
    def create_user_login(options = {})
      password = options.fetch(:password, nil)
      password_confirmation = options.fetch(:password_confirmation, nil)
      options.delete(:password)
      options.delete(:password_confirmation)
      ul = UserLogin.new(options)
      ul.password = password || 'test'
      ul.password_confirmation = password_confirmation || 'test'
      ul.save
      ul
    end
end
