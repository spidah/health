require "#{File.dirname(__FILE__)}/../test_helper"

class IntegrationMeasurementsTest < ActionController::IntegrationTest
  def test_measurements
    # inches
    spidah = new_session_as(get_user(users(:spidah)))
    spidah.login(user_logins(:spidah).openid_url)

    spidah.cant_add_incorrect_measurement(2007, 6, 1, spidah.measurement_params(0, ''), true)
    spidah.cant_add_incorrect_measurement(2007, 6, 1, spidah.measurement_params(-10, 'Left arm'), false)
    spidah.cant_add_incorrect_measurement(2007, 6, 1, spidah.measurement_params('a', 'Left arm'), false)
    spidah.add_measurement(2007, 6, 1, spidah.measurement_params(6, 'Left arm'), '---')
    spidah.add_measurement(2007, 6, 2, spidah.measurement_params(8, 'Left arm'), 'gained 2 inches')
    spidah.add_measurement(2007, 6, 1, spidah.measurement_params(10, 'Left leg'), '---')
    spidah.add_measurement(2007, 6, 2, spidah.measurement_params(7, 'Left leg'), 'lost 3 inches')

    measurement = spidah.get_measurement(2007, 6, 2, 'Left leg')
    spidah.cant_update_incorrect_measurement(measurement, spidah.measurement_params(0, ''), true)
    spidah.cant_update_incorrect_measurement(measurement, spidah.measurement_params(-10, 'Left leg'), false)
    spidah.cant_update_incorrect_measurement(measurement, spidah.measurement_params('a', 'Left leg'), false)
    spidah.cant_update_invalid_measurement_id(1000, spidah.measurement_params(0, ''))
    spidah.update_measurement(measurement, spidah.measurement_params(12, 'Left leg'), 'gained 2 inches')
    spidah.cant_delete_invalid_measurement_id(1000)
    spidah.delete_measurement(measurement)

    spidah.add_measurement(2007, 5, 30, spidah.measurement_params(4, 'Left arm'))
    spidah.check_measurement_difference(spidah.get_measurement(2007, 6, 1, 'Left arm'), 'gained 2 inches')
    spidah.add_measurement(2007, 5, 31, spidah.measurement_params(8, 'Left arm'))
    spidah.check_measurement_difference(spidah.get_measurement(2007, 5, 31, 'Left arm'), 'gained 4 inches')
    spidah.check_measurement_difference(spidah.get_measurement(2007, 6, 1, 'Left arm'), 'lost 2 inches')
    spidah.delete_measurement(spidah.get_measurement(2007, 5, 30, 'Left arm'))
    spidah.check_measurement_difference(spidah.get_measurement(2007, 5, 31, 'Left arm'), '---')
    spidah.add_measurement(2007, 5, 30, spidah.measurement_params(16, 'Left arm'))
    spidah.delete_measurement(spidah.get_measurement(2007, 5, 31, 'Left arm'))
    spidah.check_measurement_difference(spidah.get_measurement(2007, 6, 1, 'Left arm'), 'lost 10 inches')
    spidah.update_measurement(spidah.get_measurement(2007, 5, 30, 'Left arm'), spidah.measurement_params(4, 'Left arm'))
    spidah.check_measurement_difference(spidah.get_measurement(2007, 6, 1, 'Left arm'), 'gained 2 inches')

    spidah_measurement = spidah.get_measurement(2007, 6, 1, 'Left arm')

    # cm
    jimmy = new_session_as(get_user(users(:jimmy)))
    jimmy.login(user_logins(:jimmy).openid_url)

    jimmy.cant_add_incorrect_measurement(2007, 6, 1, jimmy.measurement_params(0, ''), true)
    jimmy.cant_add_incorrect_measurement(2007, 6, 1, jimmy.measurement_params(-10, 'Left arm'), false)
    jimmy.cant_add_incorrect_measurement(2007, 6, 1, jimmy.measurement_params('a', 'Left arm'), false)
    jimmy.add_measurement(2007, 6, 1, jimmy.measurement_params(6, 'Left arm'), '---')
    jimmy.add_measurement(2007, 6, 2, jimmy.measurement_params(8, 'Left arm'), 'gained 2 cm')
    jimmy.add_measurement(2007, 6, 1, jimmy.measurement_params(10, 'Left leg'), '---')
    jimmy.add_measurement(2007, 6, 2, jimmy.measurement_params(7, 'Left leg'), 'lost 3 cm')

    measurement = jimmy.get_measurement(2007, 6, 2, 'Left leg')
    jimmy.cant_update_incorrect_measurement(measurement, jimmy.measurement_params(0, ''), true)
    jimmy.cant_update_incorrect_measurement(measurement, jimmy.measurement_params(-10, 'Left arm'), false)
    jimmy.cant_update_incorrect_measurement(measurement, jimmy.measurement_params('a', 'Left arm'), false)
    jimmy.cant_update_invalid_measurement_id(1000, jimmy.measurement_params(0, ''))
    jimmy.update_measurement(measurement, jimmy.measurement_params(5, 'Left leg'), 'lost 5 cm')
    jimmy.cant_update_another_users_measurement(spidah_measurement, jimmy.measurement_params(5, 'Left leg'))
    jimmy.cant_delete_invalid_measurement_id(1000)
    jimmy.delete_measurement(measurement)
    jimmy.cant_delete_another_users_measurement(spidah_measurement)

    jimmy.add_measurement(2007, 5, 30, jimmy.measurement_params(4, 'Left arm'))
    jimmy.check_measurement_difference(jimmy.get_measurement(2007, 6, 1, 'Left arm'), 'gained 2 cm')
    jimmy.add_measurement(2007, 5, 31, jimmy.measurement_params(8, 'Left arm'))
    jimmy.check_measurement_difference(jimmy.get_measurement(2007, 5, 31, 'Left arm'), 'gained 4 cm')
    jimmy.check_measurement_difference(jimmy.get_measurement(2007, 6, 1, 'Left arm'), 'lost 2 cm')
    jimmy.delete_measurement(jimmy.get_measurement(2007, 5, 30, 'Left arm'))
    jimmy.check_measurement_difference(jimmy.get_measurement(2007, 5, 31, 'Left arm'), '---')
    jimmy.add_measurement(2007, 5, 30, jimmy.measurement_params(16, 'Left arm'))
    jimmy.delete_measurement(jimmy.get_measurement(2007, 5, 31, 'Left arm'))
    jimmy.check_measurement_difference(jimmy.get_measurement(2007, 6, 1, 'Left arm'), 'lost 10 cm')
    jimmy.update_measurement(jimmy.get_measurement(2007, 5, 30, 'Left arm'), jimmy.measurement_params(4, 'Left arm'))
    jimmy.check_measurement_difference(jimmy.get_measurement(2007, 6, 1, 'Left arm'), 'gained 2 cm')
  end

  module MeasurementTestDSL
    attr_accessor :user

    def login(openid_url)
      $mockuser = user
      post session_path, :openid_url => openid_url
      get session_path, :openid_url => openid_url, :open_id_complete => 1
      assert_dashboard_redirect
    end

    def get_measurement(year, month, day, location)
      user.measurements.find(:first, :conditions => {:taken_on => Date.new(year, month, day), :location => location})
    end
    
    def measurement_params(measurement, location)
      {:measurement => {'measurement' => measurement, 'location' => location}}
    end

    def assert_measurement_entry_data(measurement, location)
      assert_select 'legend', 'Measurement Data'
      assert_select 'div[class=form-row]', 3

      assert_select "select[id=measurement_measurement][name='measurement[measurement]']", 1
      if user.measurement_units == 'inches'
        assert_select "select[id=measurement_measurement][name='measurement[measurement]'] option", 112
      else
        assert_select "select[id=measurement_measurement][name='measurement[measurement]'] option", 300
      end
      assert_select "select[id=measurement_measurement][name='measurement[measurement]'] option[value=?][selected=selected]", measurement

      assert_select "input[id=measurement_location][name='measurement[location]']", 1
      assert_select "input[id=measurement_location][name='measurement[location]'][value=?]", location if !location.blank?
    end

    def assert_measurement_list_data(params, date, difference = nil)
      m = params[:measurement]

      assert_select 'table[class=measurements-list] tr[class=measurement-date] td' do
        assert_select 'td[class=date]', format_date(date)
      end

      assert_select 'table[class=measurements-list] tr[class=?] td', /measurement-data.*#{date.year}-#{date.month}-#{date.day}.*#{m['location'].split(' ').join('-')}/ do
        assert_select 'td[class=location]', m['location']

        if user.measurement_units == 'inches'
          assert_select 'td[class=measurement]', "#{m['measurement']} inches"
        else
          assert_select 'td[class=measurement]', "#{m['measurement']} cm"
        end
        assert_select 'td[class=difference]', difference if difference
      end
    end

    def change_date(year, month, day)
      post change_date_path, {:date_picker => format_date(Date.new(year, month, day))}

      assert_response :redirect
      follow_redirect!
      assert_response :success

      assert_select "a", format_date(Date.new(year, month, day))
    end

    def check_measurement_difference(weight, difference)
      get measurements_path
      assert_success('measurements/index')

      assert_measurement_list_data(measurement_params(weight.measurement, weight.location), weight.taken_on, difference)
    end

    def cant_add_incorrect_measurement(year, month, day, params, incorrect_location)
      change_date(year, month, day)
      get new_measurement_path
      assert_success 'measurements/new'
      assert_measurement_entry_data(1, '')

      post measurements_path, params
      assert_success 'measurements/new'

      assert_flash('error', nil, 'Error saving measurement')
      assert_flash_item('error', 'Please enter a valid measurement.')
      assert_flash_item('error', 'Please enter a valid location.') if incorrect_location
    end

    def add_measurement(year, month, day, params, difference = nil)
      change_date(year, month, day)
      get new_measurement_path
      assert_success 'measurements/new'
      assert_measurement_entry_data(1, '')

      post measurements_path, params
      assert_and_follow_redirect(measurements_path, 'measurements/index')
      assert_no_flash('error')

      assert_measurement_list_data(params, Date.new(year, month, day), difference)
    end

    def cant_update_incorrect_measurement(measurement, params, incorrect_location)
      get edit_measurement_path(measurement)
      assert_success 'measurements/edit'
      assert_measurement_entry_data(measurement.measurement, measurement.location)

      put measurement_path(measurement), params
      assert_and_follow_redirect(edit_measurement_path(measurement), 'measurements/edit')

      assert_flash('error', nil, 'Error saving measurement')
      assert_flash_item('error', 'Please enter a valid measurement.')
      assert_flash_item('error', 'Please enter a valid location.') if incorrect_location
    end

    def cant_update_invalid_measurement_id(id, params)
      get edit_measurement_path(id)
      assert_and_follow_redirect(measurements_path, 'measurements/index')
      assert_flash('error', 'Unable to edit the selected measurement.', 'Error')

      put measurement_path(id), params
      assert_and_follow_redirect(measurements_path, 'measurements/index')
      assert_flash('error', 'Unable to update the selected measurement.', 'Error')
    end
    
    def cant_update_another_users_measurement(measurement, params)
      get edit_measurement_path(measurement)
      assert_and_follow_redirect(measurements_path, 'measurements/index')
      assert_flash('error', 'Unable to edit the selected measurement.', 'Error')

      put measurement_path(measurement), params
      assert_and_follow_redirect(measurements_path, 'measurements/index')
      assert_flash('error', 'Unable to update the selected measurement.', 'Error')
    end

    def update_measurement(measurement, params, difference = nil)
      get edit_measurement_path(measurement)
      assert_success 'measurements/edit'
      assert_measurement_entry_data(measurement.measurement, measurement.location)
      
      put measurement_path(measurement), params
      assert_and_follow_redirect(measurements_path, 'measurements/index')
      assert_no_flash('error')
      assert_measurement_list_data(params, measurement.taken_on, difference)
    end

    def cant_delete_invalid_measurement_id(id)
      delete measurement_path(id)
      assert_and_follow_redirect(measurements_path, 'measurements/index')
      assert_flash('error', 'Unable to delete the selected measurement.', 'Error')
    end

    def cant_delete_another_users_measurement(measurement)
      delete measurement_path(measurement)
      assert_and_follow_redirect(measurements_path, 'measurements/index')
      assert_flash('error', 'Unable to delete the selected measurement.', 'Error')
    end

    def delete_measurement(measurement)
      delete measurement_path(measurement)
      assert_and_follow_redirect(measurements_path, 'measurements/index')
      assert_no_flash('error')
    end
  end

  def new_session_as(user)
    open_session do |session|
      session.extend(MeasurementTestDSL)
      session.user = user
      yield session if block_given?
    end
  end
end
