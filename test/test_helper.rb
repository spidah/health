ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

ActionMailer::Base.delivery_method = :test

class Test::Unit::TestCase
  def get_user(user)
    User.find(user.id)
  end
end

class ActionController::Integration::Session
  def assert_dashboard
    assert_success('users/index')
    assert_select 'h2', 'Your Dashboard'
  end

  def assert_dashboard_redirect
    assert_and_follow_redirect(dashboard_path, 'users/index')
    assert_select 'h2', 'Your Dashboard'
  end

  def assert_user_settings_redirect
    assert_and_follow_redirect(edit_user_path, 'users/edit')
  end

  def assert_and_follow_redirect(path, template)
    assert_redirected_to path
    follow_redirect!
    assert_response :success
    assert_template template
  end

  def assert_success(template)
    assert_response :success
    assert_template template
  end

  def assert_flash(type, message = nil, title = nil)
    assert_select "div[class=#{type}][id=#{type}-flash]", {:minimum => 1}
    assert_select "div[class=#{type}][id=#{type}-flash]>p", message if message
    assert_select "div[class=#{type}][id=#{type}-flash]>h5", title if title
  end

  def assert_flash_item(type, item)
    assert_select "div[class=#{type}][id=#{type}-flash]>p>span", item
  end

  def assert_flash_item_count(type, count)
    assert_select "div[class=#{type}][id=#{type}-flash]>p>span", count
  end

  def assert_no_flash(type)
    assert_select "div[class=#{type}][id=#{type}-flash]", 0
    assert_select "div[class=#{type}][id=#{type}-flash]>p", 0
    assert_select "div[class=#{type}][id=#{type}-flash]>h5", 0
  end

  def format_date(date, format = nil)
    date.strftime(format || "%d %B %Y")
  end
end

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...
  def assert_difference(object, method, difference=1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method)
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end

  fixtures :all
end

load File.join(RAILS_ROOT,'test', 'mocks', 'test', 'open_id_authentication_mock.rb')
