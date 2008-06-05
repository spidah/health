require "#{File.dirname(__FILE__)}/../test_helper"

class IntegrationUserTest < ActionController::IntegrationTest
  def test_user
    spidah = new_session
    spidah.login(user_logins(:spidah).openid_url)
    spidah.check_settings('m', 16, 8, 1982, 0, 1, 'lbs', 'inches')
    spidah.should_update_settings('f', 2, 2, 2002, 60, 0, 'kg', 'cm')
    spidah.cant_update_invalid_settings('f', 2, 2, 2002, 60, 0, 'kg', 'cm',
      'a', 31, 6, 2000, 1, -1, 'ar', 'lk')
    spidah.change_dates
    spidah.should_update_settings('m', 16, 8, 1982, 0, 1, 'lbs', 'inches')
    spidah.should_view_profile('spidah', {:about_me => 'Spidah.'})
    spidah.add_data(users(:spidah))
    spidah.should_view_profile('spidah', {:about_me => 'Spidah.', :target_weight => true, :weights => true, :measurements => true})
    spidah.cant_view_invalid_profile('nonexistingusername')
    spidah.logout

    bob = new_session
    bob.login(user_logins(:bob).openid_url)
    bob.cant_update_to_admin
    bob.logout

    amanda = new_session
    amanda.login_normal('amanda', 'test')
    amanda.cant_change_invalid_password('test')
    amanda.should_change_password('test', 'newpassword')
    amanda.logout
    amanda.login_normal('amanda', 'newpassword')
  end

  module UserTestDSL
    attr_accessor :openid_url

    def get_user
      ul = UserLogin.get(self.openid_url)
      User.find(ul.user_id)
    end

    def assert_user_data_tags
      assert_select 'legend', 'Your Data'
      assert_select "select[id=user_gender][name='user[gender]']>option", 2
      assert_select "select[id=user_dob_3i][name='user[dob(3i)]']>option", 31
      assert_select "select[id=user_dob_2i][name='user[dob(2i)]']>option", 12
      assert_select "select[id=user_dob_1i][name='user[dob(1i)]']>option", 121
      assert_select "select[id=user_timezone][name='user[timezone]']>option", 32
      assert_select "input[id=user_isdst][name='user[isdst]'][type=checkbox]", 1
    end

    def assert_user_data_values(gender, dob_day, dob_month, dob_year, timezone, dst)
      assert_select "select[id=user_gender][name='user[gender]']>option[value=?][selected=selected]", gender
      assert_select "select[id=user_dob_3i][name='user[dob(3i)]']>option[value=?][selected=selected]", dob_day
      assert_select "select[id=user_dob_2i][name='user[dob(2i)]']>option[value=?][selected=selected]", dob_month
      assert_select "select[id=user_dob_1i][name='user[dob(1i)]']>option[value=?][selected=selected]", dob_year
      assert_select "select[id=user_timezone][name='user[timezone]']>option[value=?][selected=selected]", timezone
      assert_select "input[id=user_isdst][name='user[isdst]'][type=checkbox]", 1
      assert_select "input[id=user_isdst][name='user[isdst]'][type=checkbox][checked=checked]", dst
    end

    def assert_user_units_tags
      assert_select 'legend', 'Units'
      assert_select "select[id=user_weight_units][name='user[weight_units]']>option", 2
      assert_select "select[id=user_measurement_units][name='user[measurement_units]']>option", 2
    end

    def assert_user_units_values(weight_units, measurement_units)
      assert_select "select[id=user_weight_units][name='user[weight_units]']>option[value=?][selected=selected]", weight_units
      assert_select "select[id=user_measurement_units][name='user[measurement_units]']>option[value=?][selected=selected]", measurement_units
    end

    def login(openid_url)
      self.openid_url = openid_url
      get login_path
      post session_path, :openid_url => openid_url
      get session_path, :openid_url => openid_url, :open_id_complete => 1
      assert_dashboard_redirect
    end

    def login_normal(loginname, password)
      get login_path
      post session_path, {:loginname => loginname, :password => password}
      assert_dashboard_redirect
    end

    def logout
      get logout_path
    end

    def change_date(new_year, new_month, new_day, valid = true, existing_year = nil, existing_month = nil, existing_day = nil)
      post change_date_path, {:date_picker => "#{new_year}-#{new_month}-#{new_day}"}

      assert_response :redirect
      follow_redirect!
      assert_response :success

      if valid
        assert_select "input[id=date_picker][value=?]", format_date(Date.new(new_year, new_month, new_day))
      else
        assert_select "input[id=date_picker][value=?]", format_date(Date.new(existing_year, existing_month, existing_day))
      end
    end

    def check_settings(gender, dob_day, dob_month, dob_year, timezone, dst, weight_units, measurement_units)
      get edit_user_path

      assert_success('users/edit')

      assert_user_data_tags
      assert_user_data_values(gender, dob_day, dob_month, dob_year, timezone, dst)

      assert_user_units_tags
      assert_user_units_values(weight_units, measurement_units)
    end

    def update_user(gender, dob_day, dob_month, dob_year, timezone, isdst, weight_units, measurement_units)
      put user_path, "user[gender]" => gender, "user[dob(3i)]" => dob_day,
        "user[dob(2i)]" => dob_month, "user[dob(1i)]" => dob_year, "user[timezone]" => timezone,
        "user[isdst]" => isdst, "user[weight_units]" => weight_units, "user[measurement_units]" => measurement_units
    end

    def should_update_settings(gender, dob_day, dob_month, dob_year, timezone, dst, weight_units, measurement_units)
      update_user(gender, dob_day, dob_month, dob_year, timezone, dst, weight_units, measurement_units)

      assert_and_follow_redirect(edit_user_path, 'users/edit')

      assert_flash('info', 'Your settings have been updated.')

      assert_user_data_tags
      assert_user_data_values(gender, dob_day, dob_month, dob_year, timezone, dst)

      assert_user_units_tags
      assert_user_units_values(weight_units, measurement_units)
    end

    def cant_update_invalid_settings(expected_gender, expected_dob_day, expected_dob_month, expected_dob_year, expected_timezone,
        expected_dst, expected_weight_units, expected_measurement_units, new_gender, new_dob_day, new_dob_month, new_dob_year, new_timezone,
        new_dst, new_weight_units, new_measurement_units)
      update_user(new_gender, new_dob_day, new_dob_month, new_dob_year, new_timezone, new_dst, new_weight_units, new_measurement_units)

      assert_and_follow_redirect(edit_user_path, 'users/edit')

      assert_flash('error', nil, 'Unable to update your settings')
      assert_select 'div[class=error][id=error-flash]>p>span[class=error-msg]', 5

      assert_user_data_tags
      assert_user_data_values(expected_gender, expected_dob_day, expected_dob_month, expected_dob_year, expected_timezone, expected_dst)

      assert_user_units_tags
      assert_user_units_values(expected_weight_units, expected_measurement_units)
    end

    def cant_update_to_admin
      u = get_user
      assert !u.admin

      put user_path, "user[admin]" => 1

      assert_and_follow_redirect(edit_user_path, 'users/edit')

      assert_no_flash('error')
      assert_flash('info', 'Your settings have been updated.')

      u = get_user
      assert !u.admin
    end

    def change_dates
      today = get_user.get_date
      change_date(2007, 6, 31, false, today.year, today.month, today.day)
      change_date(2007, 1, 1)
      change_date(2008, 2, 29)
      change_date(2007, 2, 29, false, 2008, 2, 29)
      change_date(2007, 6, 31, false, 2008, 2, 29)
      change_date('a', 'a', 'a', false, 2008, 2, 29)
      change_date('', '', '', false, 2008, 2, 29)
      change_date(0, 0, 0, false, 2008, 2, 29)
      change_date(-1, -1, -1, false, 2008, 2, 29)
    end

    def should_view_profile(username, profile_parts)
      get profile_path(:loginname => username)
      assert_success('users/show')

      assert_select 'h2', "#{username}'s Profile"
      assert_select 'h4', 'About Me'
      assert_select 'p[class=profile-about-me]', 1

      assert_select 'p[class=profile-about-me]', profile_parts[:about_me] ? profile_parts[:about_me] : "Unfortunately, #{@user.loginname} is a bit shy and has not written anything about themself."

      tw_count = profile_parts[:target_weight] ? 1 : 0
      assert_select 'h2', {:text => 'Target Weight', :count => tw_count}
      assert_select 'div[class=target-weight]', tw_count

      assert_select 'h2', 'Latest Entries', profile_parts[:weights] || profile_parts[:measurements] ? 1 : 0

      w_count = profile_parts[:weights] ? 1 : 0
      assert_select 'h3', {:text => 'Weights', :count => w_count}
      assert_select 'div[class=weights]', w_count

      m_count = profile_parts[:measurements] ? 1 : 0
      assert_select 'h3', {:text => 'Measurements', :count => m_count}
      assert_select 'div[class=measurements]', m_count
    end

    def cant_view_invalid_profile(username)
      get profile_path(:loginname => username)
      assert_dashboard_redirect
    end

    def add_data(user)
      if user.weight_units == 'lbs'
        post weights_path, :weight => {'stone' => 10, 'lbs' => 10}
        post targetweights_path, :weight => {'stone' => 8, 'lbs' => 0}
      else
        post weights_path, :weight => {'weight' => 50}
        post targetweights_path, :weight => {'weight' => 25}
      end

      post measurements_path, :measurement => {'measurement' => 30, 'location' => 'Arm'}
    end

    def change_password(current_password, new_password, confirm_password)
      put user_path, :current_password => current_password, :new_password => new_password, :confirm_password => confirm_password
    end

    def cant_change_invalid_password(current_password)
      change_password('wrong_password', 'foo1', 'foo2')
      assert_user_settings_redirect
      assert_flash('error', 'You did not enter your current password, please try again.')

      change_password(current_password, 'foo1', 'foo2')
      assert_user_settings_redirect
      assert_flash('error', 'Please confirm your password correctly.')
    end

    def should_change_password(current_password, new_password)
      change_password(current_password, new_password, new_password)
      assert_user_settings_redirect
      assert_flash('info', 'Your password has been updated.')
    end
  end

  def new_session
    open_session do |session|
      session.extend(UserTestDSL)
      yield session if block_given?
    end
  end
end
