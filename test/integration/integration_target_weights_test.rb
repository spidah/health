require "#{File.dirname(__FILE__)}/../test_helper"

class IntegrationTargetWeightsTest < ActionController::IntegrationTest
  def test_target_weights
    # lbs
    spidah = new_session_as(get_user(users(:spidah)))
    spidah.login(user_logins(:spidah).openid_url)
    spidah.check_no_target_weights
    spidah.cant_add_incorrect_target_weight(spidah.lbs_weight_params(0, 0))
    spidah.cant_add_incorrect_target_weight(spidah.lbs_weight_params(-10, -10))
    spidah.cant_add_incorrect_target_weight(spidah.lbs_weight_params('a', 'b'))
    spidah.check_no_target_weights
    spidah.add_target_weight(spidah.lbs_weight_params(12, 0))
    spidah.check_target_weights_count(1)
    spidah.goto_index_when_add_with_existing_target_weight(spidah.lbs_weight_params(10, 10))
    spidah.check_target_weights('12 stone 0 lbs', 'No entry', '12 stone 0 lbs')
    spidah.add_weight(2007, 6, 1, spidah.lbs_weight_params(14, 4))
    spidah.check_target_weight('12 stone 0 lbs', '14 stone 4 lbs', '2 stone 4 lbs')
    spidah.add_weight(2007, 6, 2, spidah.lbs_weight_params(11, 13))
    spidah.check_target_weights('12 stone 0 lbs', '11 stone 13 lbs', '1 lbs', "Target reached on #{format_date(Date.new(2007, 6, 2))}!")
    spidah.add_target_weight(spidah.lbs_weight_params(11, 0))
    spidah.check_target_weights_count(2)
    spidah.check_target_weights('11 stone 0 lbs', '11 stone 13 lbs', '13 lbs')
    spidah.delete_target_weight(spidah.get_latest_target_weight)
    spidah.check_target_weights_count(1)
    spidah.check_target_weights('12 stone 0 lbs', '11 stone 13 lbs', '1 lbs', "Target reached on #{format_date(Date.new(2007, 6, 2))}!")
    spidah.delete_weight(2007, 6, 2)
    spidah.check_target_weights('12 stone 0 lbs', '14 stone 4 lbs', '2 stone 4 lbs')
    spidah.delete_weight(2007, 6, 1)
    spidah.check_target_weights('12 stone 0 lbs', 'No entry', '12 stone 0 lbs')
    spidah.delete_target_weight(spidah.get_latest_target_weight)
    spidah.check_no_target_weights
    spidah.cant_delete_invalid_target_weight_id(1000)
    spidah.add_target_weight(spidah.lbs_weight_params(10, 0))
    spidah.check_target_weights_count(1)
    spidah_target_weight = spidah.get_latest_target_weight

    # kg
    jimmy = new_session_as(get_user(users(:jimmy)))
    jimmy.login(user_logins(:jimmy).openid_url)
    jimmy.check_no_target_weights
    jimmy.cant_add_incorrect_target_weight(jimmy.kg_weight_params(0))
    jimmy.cant_add_incorrect_target_weight(jimmy.kg_weight_params(-10))
    jimmy.cant_add_incorrect_target_weight(jimmy.kg_weight_params('a'))
    jimmy.check_no_target_weights
    jimmy.add_target_weight(jimmy.kg_weight_params(50))
    jimmy.check_target_weights_count(1)
    jimmy.check_target_weights('50 kg', 'No entry', '50 kg')
    jimmy.add_weight(2007, 6, 1, jimmy.kg_weight_params(75))
    jimmy.check_target_weights('50 kg', '75 kg', '25 kg')
    jimmy.add_weight(2007, 6, 2, jimmy.kg_weight_params(25))
    jimmy.check_target_weights('50 kg', '25 kg', '25 kg', "Target reached on #{format_date(Date.new(2007, 6, 2))}!")
    jimmy.add_target_weight(jimmy.kg_weight_params(20))
    jimmy.check_target_weights_count(2)
    jimmy.check_target_weights('20 kg', '25 kg', '5 kg')
    jimmy.delete_target_weight(jimmy.get_latest_target_weight)
    jimmy.check_target_weights_count(1)
    jimmy.check_target_weights('50 kg', '25 kg', '25 kg', "Target reached on #{format_date(Date.new(2007, 6, 2))}!")
    jimmy.delete_weight(2007, 6, 2)
    jimmy.check_target_weights('50 kg', '75 kg', '25 kg')
    jimmy.delete_weight(2007, 6, 1)
    jimmy.check_target_weights('50 kg', 'No entry', '50 kg')
    jimmy.delete_target_weight(jimmy.get_latest_target_weight)
    jimmy.check_no_target_weights
    jimmy.cant_delete_another_users_target_weight(spidah_target_weight)
  end

  module TargetWeightTestDSL
    attr_accessor :user, :current_date

    def login(openid_url)
      $mockuser = user
      post session_path, :openid_url => openid_url
      get session_path, :openid_url => openid_url, :open_id_complete => 1
      assert_dashboard_redirect
    end

    def lbs_weight_params(stone, lbs)
      {:weight => {'stone' => stone, 'lbs' => lbs}}
    end

    def kg_weight_params(kg)
      {:weight => {'weight' => kg}}
    end

    def assert_target_weight_entry_data(stone, lbs, kg)
      assert_select 'legend', 'Target Weight Data'
      assert_select 'div[class=form-row]', 2
      
      if user.weight_units == 'lbs'
        assert_select "select[id=weight_stone][name='weight[stone]']", 1
        assert_select "select[id=weight_stone][name='weight[stone]'] option", 51
        assert_select "select[id=weight_stone][name='weight[stone]'] option[value=?][selected=selected]", stone

        assert_select "select[id=weight_lbs][name='weight[lbs]']", 1
        assert_select "select[id=weight_lbs][name='weight[lbs]'] option", 14
        assert_select "select[id=weight_lbs][name='weight[lbs]'] option[value=?][selected=selected]", lbs
      else
        assert_select "select[id=weight_weight][name='weight[weight]']", 1
        assert_select "select[id=weight_weight][name='weight[weight]'] option", 401
        assert_select "select[id=weight_weight][name='weight[weight]'] option[value=?][selected=selected]", kg
      end
    end

    def assert_target_weight_item(target_weight, current_weight, difference, achieved_on = nil)
      assert_select "table[id=target-weight]", 1
      assert_select "table[id=target-weight] td[class=target-weight-target]", target_weight
      assert_select "table[id=target-weight] td[class=target-weight-current]", current_weight
      if achieved_on
        assert_select "table[id=target-weight] td[class=target-weight-completed]", achieved_on
      else
        assert_select "table[id=target-weight] td[class=target-weight-difference]", difference
      end
    end

    def change_date(year, month, day)
      post change_date_path, {:date_picker => format_date(Date.new(year, month, day))}

      assert_response :redirect
      follow_redirect!
      assert_response :success

      assert_select "input[id=date_picker][value=?]", format_date(Date.new(year, month, day))
    end

    def get_latest_target_weight
      user.target_weights.get_latest
    end

    def check_dashboard(target_weight, current_weight, difference, achieved_on = nil)
      get dashboard_path
      assert_success 'users/index'
      assert_select 'h2', 'Target Weight'
      assert_target_weight_item(target_weight, current_weight, difference, achieved_on)
    end

    def check_target_weight(target_weight, current_weight, difference, achieved_on = nil)
      get targetweights_path
      assert_success('target_weights/index')

      assert_target_weight_item(target_weight, current_weight, difference, achieved_on)
    end

    def check_target_weights(target_weight, current_weight, difference, achieved_on = nil)
      check_dashboard(target_weight, current_weight, difference, achieved_on)
      check_target_weight(target_weight, current_weight, difference, achieved_on)
    end

    def check_target_weights_count(count)
      assert_equal count, user.target_weights.find(:all).size
    end

    def check_no_target_weights
      check_target_weights_count(0)

      get targetweights_path
      assert_success('target_weights/index')
      assert_select 'p[class=target-weight-add]', 'Please add a target weight. Target weights let you see how well you are doing.'

      get dashboard_path
      assert_success('users/index')
      assert_select 'h2', {:text => 'Target Weight', :count => 0}
    end

    def add_weight(year, month, day, params)
      change_date(year, month, day)
      get new_weight_path
      post weights_path, params
      assert_and_follow_redirect(weights_path, 'weights/index')
      assert_no_flash('error')
    end

    def delete_weight(year, month, day)
      weight = user.weights.find(:first, :conditions => {:taken_on => Date.new(year, month, day)})
      delete weight_path(weight)
      assert_and_follow_redirect(weights_path, 'weights/index')
      assert_no_flash('error')
    end

    def cant_add_incorrect_target_weight(params)
      get new_targetweight_path
      assert_success 'target_weights/new'
      assert_target_weight_entry_data(0, 0, 0)

      post targetweights_path, params
      assert_success('target_weights/new')

      assert_flash('error', nil, 'Error saving target weight')
      assert_flash_item('error', 'Please enter a valid weight.')
    end

    def add_target_weight(params)
      get new_targetweight_path
      assert_success 'target_weights/new'
      assert_target_weight_entry_data(0, 0, 0)

      post targetweights_path, params
      assert_and_follow_redirect(targetweights_path, 'target_weights/index')
      assert_no_flash('error')

      target_weight = user.target_weights.get_latest
      if user.weight_units == 'lbs'
        assert_equal target_weight.stone, params[:weight]['stone']
        assert_equal target_weight.lbs, params[:weight]['lbs']
        assert_equal target_weight.weight, (params[:weight]['stone'] * 14) + params[:weight]['lbs']
      else
        assert_equal target_weight.weight, params[:weight]['weight']
      end
    end

    def goto_index_when_add_with_existing_target_weight(params)
      get new_targetweight_path
      assert_and_follow_redirect(targetweights_path, 'target_weights/index')

      post targetweights_path, params
      assert_and_follow_redirect(targetweights_path, 'target_weights/index')
    end

    def cant_delete_invalid_target_weight_id(id)
      delete targetweight_path(id)
      assert_and_follow_redirect(targetweights_path, 'target_weights/index')
      assert_flash('error', 'Unable to delete the target weight.')
    end

    def cant_delete_another_users_target_weight(target_weight)
      delete targetweight_path(target_weight)
      assert_and_follow_redirect(targetweights_path, 'target_weights/index')
      assert_flash('error', 'Unable to delete the target weight.')
    end

    def delete_target_weight(target_weight)
      delete targetweight_path(target_weight)
      assert_and_follow_redirect(targetweights_path, 'target_weights/index')
      assert_no_flash('error')
    end
  end

  def new_session_as(user)
    open_session do |session|
      session.extend(TargetWeightTestDSL)
      session.user = user
      yield session if block_given?
    end
  end
end
