require "#{File.dirname(__FILE__)}/../test_helper"

class IntegrationWeightsTest < ActionController::IntegrationTest
  def test_weights
    # lbs
    spidah = new_session_as(:spidah)
    spidah.login(spidah.user, spidah.openid_url)

    spidah.cant_add_incorrect_weight(2007, 6, 1, spidah.lbs_weight_params(0, 0))
    spidah.cant_add_incorrect_weight(2007, 6, 1, spidah.lbs_weight_params(-10, -10))
    spidah.cant_add_incorrect_weight(2007, 6, 1, spidah.lbs_weight_params('a', 'b'))
    spidah.add_weight(2007, 6, 1, spidah.lbs_weight_params(14, 4), '---')
    spidah.add_weight(2007, 6, 2, spidah.lbs_weight_params(14, 8), 'gained 4 lbs')
    spidah.add_weight(2007, 6, 3, spidah.lbs_weight_params(12, 8), 'lost 2 stone')
    spidah.add_weight(2007, 6, 4, spidah.lbs_weight_params(13, 9), 'gained 1 stone 1 lb')
    spidah.add_weight(2007, 6, 5, spidah.lbs_weight_params(12, 8), 'lost 1 stone 1 lb')

    weight = spidah.get_weight(2007, 6, 5)
    spidah.goto_edit_when_add_on_existing_date(weight, spidah.lbs_weight_params(12, 6))
    spidah.cant_update_incorrect_weight(weight, spidah.lbs_weight_params(0, -10))
    spidah.cant_update_incorrect_weight(weight, spidah.lbs_weight_params(0, 0))
    spidah.cant_update_incorrect_weight(weight, spidah.lbs_weight_params('a', 'b'))
    spidah.cant_update_invalid_weight_id(1000, spidah.lbs_weight_params(14, 10))
    spidah.update_weight(weight, spidah.lbs_weight_params(14, 10), 'gained 1 stone 1 lb')
    spidah.cant_delete_invalid_weight_id(1000)
    spidah.delete_weight(weight)

    spidah.add_weight(2007, 5, 30, spidah.lbs_weight_params(14, 0))
    spidah.check_weight_difference(spidah.get_weight(2007, 6, 1), 'gained 4 lbs')
    spidah.add_weight(2007, 5, 31, spidah.lbs_weight_params(14, 2))
    spidah.check_weight_difference(spidah.get_weight(2007, 5, 31), 'gained 2 lbs')
    spidah.check_weight_difference(spidah.get_weight(2007, 6, 1), 'gained 2 lbs')
    spidah.delete_weight(spidah.get_weight(2007, 5, 30))
    spidah.check_weight_difference(spidah.get_weight(2007, 5, 31), '---')
    spidah.add_weight(2007, 5, 30, spidah.lbs_weight_params(14, 8))
    spidah.delete_weight(spidah.get_weight(2007, 5, 31))
    spidah.check_weight_difference(spidah.get_weight(2007, 6, 1), 'lost 4 lbs')
    spidah.update_weight(spidah.get_weight(2007, 5, 30), spidah.lbs_weight_params(14, 10))
    spidah.check_weight_difference(spidah.get_weight(2007, 6, 1), 'lost 6 lbs')

    spidah_weight = spidah.get_weight(2007, 6, 1)

    spidah.cant_change_taken_on_date('2007-06-08', spidah_weight)

    bob = new_session_as(:bob)
    bob.login(bob.user, bob.openid_url)

    # adding a new weight with the same date as a weight by another user, but unique for this user
    bob.add_weight(2007, 6, 1, bob.lbs_weight_params(7, 2))
    bob.cant_update_another_users_weight(spidah_weight, bob.lbs_weight_params(14, 10))
    bob.cant_delete_another_users_weight(spidah_weight)
    bob.delete_weight(bob.get_weight(2007, 6, 1))
    bob.add_weight(2007, 6, 1, bob.lbs_weight_params(0, 6))
    bob.add_weight(2007, 6, 2, bob.lbs_weight_params(0, 8))
    bob.check_weight_difference(bob.get_weight(2007, 6, 2), 'gained 2 lbs')
    bob.add_weight(2007, 6, 3, bob.lbs_weight_params(0, 9))
    bob.check_weight_difference(bob.get_weight(2007, 6, 2), 'gained 1 lb')

    # kg
    jimmy = new_session_as(:jimmy)
    jimmy.login(jimmy.user, jimmy.openid_url)
    jimmy.cant_add_incorrect_weight(2007, 6, 1, jimmy.kg_weight_params(0))
    jimmy.cant_add_incorrect_weight(2007, 6, 1, jimmy.kg_weight_params(-10))
    jimmy.cant_add_incorrect_weight(2007, 6, 1, jimmy.kg_weight_params('a'))
    jimmy.add_weight(2007, 6, 1, jimmy.kg_weight_params(50), '---')
    jimmy.add_weight(2007, 6, 2, jimmy.kg_weight_params(100), 'gained 50 kg')
    jimmy.add_weight(2007, 6, 3, jimmy.kg_weight_params(75), 'lost 25 kg')

    weight = jimmy.get_weight(2007, 6, 3)
    jimmy.cant_update_incorrect_weight(weight, jimmy.kg_weight_params(0))
    jimmy.cant_update_incorrect_weight(weight, jimmy.kg_weight_params(-10))
    jimmy.cant_update_incorrect_weight(weight, jimmy.kg_weight_params('a'))
    jimmy.update_weight(weight, jimmy.kg_weight_params(70), 'lost 30 kg')

    jimmy.add_weight(2007, 5, 30, jimmy.kg_weight_params(25))
    jimmy.check_weight_difference(jimmy.get_weight(2007, 6, 1), 'gained 25 kg')
    jimmy.add_weight(2007, 5, 31, jimmy.kg_weight_params(30))
    jimmy.check_weight_difference(jimmy.get_weight(2007, 5, 31), 'gained 5 kg')
    jimmy.check_weight_difference(jimmy.get_weight(2007, 6, 1), 'gained 20 kg')
    jimmy.delete_weight(jimmy.get_weight(2007, 5, 30))
    jimmy.check_weight_difference(jimmy.get_weight(2007, 5, 31), '---')
    jimmy.add_weight(2007, 5, 30, jimmy.kg_weight_params(60))
    jimmy.delete_weight(jimmy.get_weight(2007, 5, 31))
    jimmy.check_weight_difference(jimmy.get_weight(2007, 6, 1), 'lost 10 kg')
    jimmy.update_weight(jimmy.get_weight(2007, 5, 30), jimmy.kg_weight_params(55))
    jimmy.check_weight_difference(jimmy.get_weight(2007, 6, 1), 'lost 5 kg')
  end

  module WeightTestDSL
    attr_accessor :user, :openid_url, :current_date

    def get_weight(year, month, day)
      user.weights.find(:first, :conditions => {:taken_on => Date.new(year, month, day)})
    end
    
    def lbs_weight_params(stone, lbs)
      {:weight => {'stone' => stone, 'lbs' => lbs}}
    end

    def kg_weight_params(kg)
      {:weight => {'weight' => kg}}
    end

    def assert_weight_entry_data(stone, lbs, kg, date = nil)
      assert_select('legend', 'Weight Data')
      assert_select('div[class=form-row]', 2)
      
      if user.weight_units == 'lbs'
        assert_select("select[id=weight_stone][name='weight[stone]']", 1)
        assert_select("select[id=weight_stone][name='weight[stone]'] option", 51)
        assert_select("select[id=weight_stone][name='weight[stone]'] option[value=?][selected=selected]", stone)

        assert_select("select[id=weight_lbs][name='weight[lbs]']", 1)
        assert_select("select[id=weight_lbs][name='weight[lbs]'] option", 14)
        assert_select("select[id=weight_lbs][name='weight[lbs]'] option[value=?][selected=selected]", lbs)
      else
        assert_select("select[id=weight_weight][name='weight[weight]']", 1)
        assert_select("select[id=weight_weight][name='weight[weight]'] option", 401)
        assert_select("select[id=weight_weight][name='weight[weight]'] option[value=?][selected=selected]", kg)
      end

      assert_select('h2', "Edit Weight For #{format_date(date)}") if date
    end

    def assert_weight_list_data(params, date, difference)
      weight = Weight.new({:weight_units => user.weight_units}.merge(params[:weight]))

      assert_select('table[class=weights-list] tr[class=?] td', /weight-data.*/) do
        assert_select('td[class=date]', format_date(date))
        assert_select('td[class=weight]', weight.format)
        assert_select('td[class=difference]', difference) if difference
      end
    end

    def assert_weight_list_data_from_weight(weight, date, difference = nil)
      weight.weight_units = user.weight_units
      assert_select('table[class=weights-list] tr[class=?] td', /weight-data.*/) do
        assert_select('td[class=date]', format_date(weight.taken_on))
        assert_select('td[class=weight]', weight.format)
        assert_select('td[class=difference]', difference) if difference
      end
    end

    def check_weight_difference(weight, difference)
      get(weights_path)
      assert_success('weights/index')

      if user.weight_units == 'lbs'
        assert_weight_list_data(lbs_weight_params(weight.stone, weight.lbs), weight.taken_on, difference)
      else
        assert_weight_list_data(kg_weight_params(weight.weight), weight.taken_on, difference)
      end
    end

    def cant_add_incorrect_weight(year, month, day, params)
      change_date(Date.new(year, month, day))
      get(new_weight_path)
      assert_success('weights/new')

      assert_weight_entry_data(0, 0, 0)

      post(weights_path, params)
      assert_success('weights/new')

      assert_flash('error', nil, 'Error saving weight')
      assert_flash_item('error', 'Please enter a valid weight.')
    end

    def add_weight(year, month, day, params, difference = nil)
      change_date(Date.new(year, month, day))
      get(new_weight_path)
      assert_success('weights/new')

      assert_weight_entry_data(0, 0, 0)

      post(weights_path, params)
      assert_and_follow_redirect(weights_path, 'weights/index')
      assert_no_flash('error')

      assert_weight_list_data(params, Date.new(year, month, day), difference)
    end

    def goto_edit_when_add_on_existing_date(weight, params)
      change_date(Date.new(weight.taken_on.year, weight.taken_on.month, weight.taken_on.day))
      get(new_weight_path)
      assert_and_follow_redirect(edit_weight_path(weight), 'weights/edit')
    end

    def cant_update_incorrect_weight(weight, params)
      get(edit_weight_path(weight))
      assert_success('weights/edit')

      assert_weight_entry_data(weight.stone, weight.lbs, weight.weight, weight.taken_on)

      put(weight_path(weight), params)
      assert_and_follow_redirect(edit_weight_path(weight), 'weights/edit')

      assert_flash('error', nil, 'Error saving weight')
      assert_flash_item('error', 'Please enter a valid weight.')
    end

    def cant_update_invalid_weight_id(id, params)
      get(edit_weight_path(id))

      assert_and_follow_redirect(weights_path, 'weights/index')
      assert_flash('error', 'Unable to find the selected weight.')

      put(weight_path(id), params)
      assert_and_follow_redirect(weights_path, 'weights/index')
      assert_flash('error', 'Unable to find the selected weight.', 'Error')
    end

    def cant_change_taken_on_date(date, weight)
      put(weight_path(weight), :weight => {:taken_on => date})

      assert_and_follow_redirect(weights_path, 'weights/index')
      assert_no_flash('error')
      assert_weight_list_data_from_weight(weight, date)
    end

    def update_weight(weight, params, difference = nil)
      get(edit_weight_path(weight))
      assert_success('weights/edit')
      assert_weight_entry_data(weight.stone, weight.lbs, weight.weight, weight.taken_on)

      put(weight_path(weight), params)
      assert_and_follow_redirect(weights_path, 'weights/index')
      assert_no_flash('error')
      assert_weight_list_data(params, weight.taken_on, difference)
    end

    def cant_delete_invalid_weight_id(id)
      delete(weight_path(id))
      assert_and_follow_redirect(weights_path, 'weights/index')
      assert_flash('error', 'Unable to find the selected weight.', 'Error')
    end

    def delete_weight(weight)
      delete(weight_path(weight))
      assert_and_follow_redirect(weights_path, 'weights/index')
      assert_no_flash('error')
    end

    def cant_update_another_users_weight(weight, params)
      get(edit_weight_path(weight))
      assert_and_follow_redirect(weights_path, 'weights/index')
      assert_flash('error', 'Unable to find the selected weight.', 'Error')

      put(weight_path(weight), params)
      assert_and_follow_redirect(weights_path, 'weights/index')
      assert_flash('error', 'Unable to find the selected weight.', 'Error')
    end

    def cant_delete_another_users_weight(weight)
      delete(weight_path(weight))
      assert_and_follow_redirect(weights_path, 'weights/index')
      assert_flash('error', 'Unable to find the selected weight.', 'Error')
    end
  end

  def new_session_as(user)
    open_session do |session|
      session.extend(WeightTestDSL)
      session.user = get_user(users(user))
      session.openid_url = user_logins(user).openid_url
      yield session if block_given?
    end
  end
end
