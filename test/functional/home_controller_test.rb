require File.dirname(__FILE__) + '/../test_helper'

class HomeControllerTest < ActionController::TestCase
  def test_home
    get(:index)
    assert_response(:success)
    assert_template('home/index')
    assert_equal(3, assigns(:news).size)

    user = User.create(:dob => Date.today, :gender => 'm', :weight_units => 'lbs', :measurement_units => 'inches', :timezone => 0,
      :loginname => 'newuser', :email => 'foo@foo.foo')
    openid = UserLogin.create(:openid_url => 'http://newuser.myopenid.com', :user_id => user.id, :linked_to => 0)

    get(:index, nil, {:user_id => user.id, :user_login_id => openid.id})
    assert_redirected_to(:controller => 'users', :action => 'index')
  end
end
