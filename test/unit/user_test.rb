require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  def setup
    @valid_attributes = {:loginname => 'newuser', :email => 'spidahman@gmail.com', :gender => 'm', :dob => Date.today,
      :timezone => 'London', :weight_units => 'lbs', :measurement_units => 'inches'}
  end

  def test_should_create_user
    u = User.create(@valid_attributes)
    assert(!u.new_record?, "#{u.errors.full_messages.to_sentence}")

    u = User.create(@valid_attributes.merge({:loginname => 'newuser1', :weight_units => 'kg', :measurement_units => 'cm'}))
    assert(!u.new_record?, "#{u.errors.full_messages.to_sentence}")
  end

  def test_should_require_loginname
    u = User.create(@valid_attributes.except(:loginname))
    assert(!u.valid?)
    assert(u.errors.on(:loginname))
  end

  def test_should_require_unique_loginname
    u = User.create(@valid_attributes)
    assert(u.valid?, "#{u.errors.full_messages.to_sentence}")

    u = User.create(@valid_attributes)
    assert(u.new_record?)
    assert(u.errors.on(:loginname))
  end

  def test_should_require_valid_loginname
    u = User.create(@valid_attributes.merge({:loginname => 'newuser!'}))
    assert(u.errors.on(:loginname))
  end

  def test_should_convert_invalid_gender_to_m
    u = User.create(@valid_attributes.merge({:gender => 'a'}))
    assert(u.valid?, u.errors.full_messages.to_sentence)
    assert_equal('m', u.gender)
  end

  def test_should_downcase_gender
    u = User.create(@valid_attributes.merge({:gender => 'M'}))
    assert(u.valid?, u.errors.full_messages.to_sentence)
    assert_equal('m', u.gender)

    u.update_attributes(:gender => 'F')
    assert(u.valid?, u.errors.full_messages.to_sentence)
    assert_equal('f', u.gender)
  end

  def test_should_require_valid_units
    u = User.create(@valid_attributes.merge({:weight_units => 'a', :measurement_units => 'b'}))
    assert(u.errors.on(:weight_units))
    assert(u.errors.on(:measurement_units))
  end

  def test_should_strip_html_from_aboutme_text
    u = User.create(@valid_attributes.merge({:profile_aboutme => 'This is just some <b>sample</b> <script type="javascript">text</script>.'}))
    assert_equal('This is just some sample text.', u.profile_aboutme)
  end

  def test_should_return_admin_pagination
    users = User.admin_pagination(1)
    assert(users)
    assert_equal(4, users.size)

    (1..20).each { |i|
      User.create(@valid_attributes.merge({:loginname => "newuser#{i}", :email => "spidahman#{i}@gmail.com"}))
    }

    users = User.admin_pagination(1)
    assert(users)
    assert_equal(20, users.size)

    users = User.admin_pagination(2)
    assert(users)
    assert_equal(4, users.size)
  end

  def test_should_update
    u = User.create(@valid_attributes)
    
    assert_equal('spidahman@gmail.com', u.email)
    assert_equal('m', u.gender)
    assert_equal(Date.today, u.dob)
    assert_equal('London', u.timezone)
    assert_equal('lbs', u.weight_units)
    assert_equal('inches', u.measurement_units)

    u.update_attributes(:email => 'spidah@gmail.com', :gender => 'f', :dob => Date.tomorrow, :timezone => 'Stockholm',
      :weight_units => 'kg', :measurement_units => 'cm')
    u.reload

    assert_equal('spidah@gmail.com', u.email)
    assert_equal('f', u.gender)
    assert_equal(Date.tomorrow, u.dob)
    assert_equal('Stockholm', u.timezone)
    assert_equal('kg', u.weight_units)
    assert_equal('cm', u.measurement_units)
  end

  def test_should_return_correct_user_date
    u = User.create(@valid_attributes.merge({:timezone => "Nuku'alofa"}))
    assert_equal((Time.now + 13.hours).to_date, u.get_date)

    u.update_attributes(:timezone => 'Samoa')
    u.reload
    assert_equal((Time.now - 11.hours).to_date, u.get_date)
  end

  def test_cant_update_to_admin
    user = User.create(@valid_attributes)
    assert(!user.admin)

    user.update_attributes(:admin => true)
    user.reload

    assert(!user.admin)
  end

  def test_should_destroy
    user = User.create(@valid_attributes)
    user.destroy
    assert_raise(ActiveRecord::RecordNotFound) { User.find(user.id) }
  end
end
