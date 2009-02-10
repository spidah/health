require "#{File.dirname(__FILE__)}/../test_helper"

class IntegrationUserTest < ActionController::IntegrationTest
  def test_user
    spidah = new_session_as(:spidah)
    spidah.login(spidah.user, spidah.openid_url)
    spidah.check_settings('m', 16, 8, 1982, 'London', 'lbs', 'inches')
    spidah.should_update_settings('f', 2, 2, 2002, 'Stockholm', 'kg', 'cm')
    spidah.cant_update_invalid_settings('f', 2, 2, 2002, 'Stockholm', 'kg', 'cm',
      'a', 31, 6, 2000, 'Invalid', 'ar', 'lk')
    spidah.change_dates
    spidah.should_update_settings('m', 16, 8, 1982, 'London', 'lbs', 'inches')
    spidah.should_view_profile('spidah', {:about_me => 'Spidah.'})
    spidah.add_data(users(:spidah))
    spidah.should_view_profile('spidah', {:about_me => 'Spidah.', :target_weight => true, :weight => true})
    spidah.cant_view_invalid_profile('nonexistingusername')

    spidah.check_menu_changes_from_add_to_edit_when_values_are_added
    spidah.logout

    bob = new_session_as(:bob)
    bob.login(bob.user, bob.openid_url)
    bob.cant_update_to_admin
    bob.logout

    amanda = new_session_as(:amanda)
    amanda.login_normal('amanda', 'test')
    amanda.cant_change_invalid_password('test')
    amanda.should_change_password('test', 'newpassword')
    amanda.logout
    amanda.login_normal('amanda', 'newpassword')
  end

  module UserTestDSL
    attr_accessor :user, :openid_url

    def get_user
      ul = UserLogin.get(self.openid_url)
      User.find(ul.user_id)
    end

    def assert_user_data_tags
      assert_select('legend', 'Your Data')
      assert_select("select[id=user_gender][name='user[gender]']>option", 2)
      assert_select("select[id=user_dob_3i][name='user[dob(3i)]']>option", 31)
      assert_select("select[id=user_dob_2i][name='user[dob(2i)]']>option", 12)
      assert_select("select[id=user_dob_1i][name='user[dob(1i)]']>option", 121)
      assert_select("select[id=user_timezone][name='user[timezone]']>option", :minimum => 1)
    end

    def assert_user_data_values(gender, dob_day, dob_month, dob_year, timezone)
      assert_select("select[id=user_gender][name='user[gender]']>option[value=?][selected=selected]", gender)
      assert_select("select[id=user_dob_3i][name='user[dob(3i)]']>option[value=?][selected=selected]", dob_day)
      assert_select("select[id=user_dob_2i][name='user[dob(2i)]']>option[value=?][selected=selected]", dob_month)
      assert_select("select[id=user_dob_1i][name='user[dob(1i)]']>option[value=?][selected=selected]", dob_year)
      assert_select("select[id=user_timezone][name='user[timezone]']>option[selected=selected]", /#{timezone}/)
    end

    def assert_user_units_tags
      assert_select('legend', 'Units')
      assert_select("select[id=user_weight_units][name='user[weight_units]']>option", 2)
      assert_select("select[id=user_measurement_units][name='user[measurement_units]']>option", 2)
    end

    def assert_user_units_values(weight_units, measurement_units)
      assert_select("select[id=user_weight_units][name='user[weight_units]']>option[value=?][selected=selected]", weight_units)
      assert_select("select[id=user_measurement_units][name='user[measurement_units]']>option[value=?][selected=selected]", measurement_units)
    end

    def login_normal(loginname, password)
      get(login_path)
      post(session_path, {:loginname => loginname, :password => password})
      assert_dashboard_redirect
    end

    def logout
      delete(logout_path)
    end

    def change_date(new_year, new_month, new_day, valid = true, existing_year = nil, existing_month = nil, existing_day = nil)
      post(change_date_path, {:date_picker => "#{new_year}-#{new_month}-#{new_day}"})

      assert_response(:redirect)
      follow_redirect!
      assert_response(:success)

      if valid
        assert_select('a', format_date(Date.new(new_year, new_month, new_day)))
      else
        assert_select('a', format_date(Date.new(existing_year, existing_month, existing_day)))
      end
    end

    def check_settings(gender, dob_day, dob_month, dob_year, timezone, weight_units, measurement_units)
      get(edit_user_path)

      assert_success('users/edit')

      assert_user_data_tags
      assert_user_data_values(gender, dob_day, dob_month, dob_year, timezone)

      assert_user_units_tags
      assert_user_units_values(weight_units, measurement_units)
    end

    def update_user(gender, dob_day, dob_month, dob_year, timezone, weight_units, measurement_units)
      put(user_path, "user[gender]" => gender, "user[dob(3i)]" => dob_day,
        "user[dob(2i)]" => dob_month, "user[dob(1i)]" => dob_year, "user[timezone]" => timezone,
        "user[weight_units]" => weight_units, "user[measurement_units]" => measurement_units)
    end

    def should_update_settings(gender, dob_day, dob_month, dob_year, timezone, weight_units, measurement_units)
      update_user(gender, dob_day, dob_month, dob_year, timezone, weight_units, measurement_units)

      assert_and_follow_redirect(edit_user_path, 'users/edit')

      assert_flash('info', 'Your settings have been updated.')

      assert_user_data_tags
      assert_user_data_values(gender, dob_day, dob_month, dob_year, timezone)

      assert_user_units_tags
      assert_user_units_values(weight_units, measurement_units)
    end

    def cant_update_invalid_settings(expected_gender, expected_dob_day, expected_dob_month, expected_dob_year, expected_timezone,
        expected_weight_units, expected_measurement_units, new_gender, new_dob_day, new_dob_month, new_dob_year, new_timezone,
        new_weight_units, new_measurement_units)
      update_user(new_gender, new_dob_day, new_dob_month, new_dob_year, new_timezone, new_weight_units, new_measurement_units)

      assert_and_follow_redirect(edit_user_path, 'users/edit')

      assert_flash('error', nil, 'Unable to update your settings')
      assert_select 'div[class=flash][id=error-flash]>p>span[class=error-msg]', 3

      assert_user_data_tags
      assert_user_data_values(expected_gender, expected_dob_day, expected_dob_month, expected_dob_year, expected_timezone)

      assert_user_units_tags
      assert_user_units_values(expected_weight_units, expected_measurement_units)
    end

    def cant_update_to_admin
      u = get_user
      assert !u.admin

      put(user_path, "user[admin]" => 1)

      assert_and_follow_redirect(edit_user_path, 'users/edit')

      assert_no_flash('error')
      assert_flash('info', 'Your settings have been updated.')

      u = get_user
      assert(!u.admin)
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
      get(profile_path(username))
      assert_success('users/show')

      assert_select('h2', "#{username}'s Profile")
      assert_select('h4', 'About Me')
      assert_select('p[class=profile-about-me]', 1)

      assert_select('p[class=profile-about-me]', profile_parts[:about_me] ? profile_parts[:about_me] : "Unfortunately, #{@user.loginname} is a bit shy and has not written anything about themself.")

      assert_select('span', {:text => 'Target weight:', :count => profile_parts[:target_weight] ? 1 : 0})
      assert_select('span', {:text => 'Current weight:', :count => profile_parts[:weight] ? 1 : 0})
    end

    def cant_view_invalid_profile(username)
      get(profile_path(:loginname => username))
      assert_dashboard_redirect
    end

    def add_data(user)
      if user.weight_units == 'lbs'
        post(weights_path, :weight => {'stone' => 10, 'lbs' => 10})
        post(targetweights_path, :weight => {'stone' => 8, 'lbs' => 0})
      else
        post(weights_path, :weight => {'weight' => 50})
        post(targetweights_path, :weight => {'weight' => 25})
      end

      post(measurements_path, :measurement => {'measurement' => 30, 'location' => 'Arm'})
    end

    def change_password(current_password, new_password, confirm_password)
      put(user_path, :current_password => current_password, :new_password => new_password, :confirm_password => confirm_password)
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

    def check_menu_changes_from_add_to_edit_when_values_are_added
      date = Date.today - 1.year
      post(change_date_path, :date_picker => date)
      get(dashboard_path)
      assert_select('a[href=/weights/new]', 'Add Weight')

      post(weights_path, :weight => {'stone' => 12, 'lbs' => 4})
      weight = user.weights.find(:first, :conditions => {:taken_on => date})

      get(dashboard_path)
      assert_select("a[href=/weights/#{weight.id}/edit]", 'Edit Weight')

      delete(weight_path(weight.id))
      get(dashboard_path)
      assert_select('a[href=/weights/new]', 'Add Weight')
    end
  end

  def new_session_as(user)
    open_session do |session|
      session.extend(UserTestDSL)
      session.user = get_user(users(user))
      session.openid_url = user_logins(user).openid_url
      yield session if block_given?
    end
  end
end
