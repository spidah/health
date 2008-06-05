require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  def create_user(*attrs)
    params = attrs.extract_options!
    User.create(params)
  end

  def test_should_create_user
    u = create_user(:loginname => 'newuser', :email => 'spidahman@gmail.com', :gender => 'm', :dob => Date.today,
      :timezone => 0, :isdst => 0, :weight_units => 'lbs', :measurement_units => 'inches')
    assert !u.new_record?, "#{u.errors.full_messages.to_sentence}"

    u = create_user(:loginname => 'newuser2', :email => 'spidahman@gmail.com', :gender => 'm', :dob => Date.today,
      :timezone => 0, :isdst => 0, :weight_units => 'kg', :measurement_units => 'cm')
    assert !u.new_record?, "#{u.errors.full_messages.to_sentence}"
  end

  def test_should_require_loginname
    u = create_user(:email => 'spidahman@gmail.com', :gender => 'm', :dob => Date.today,
      :timezone => 0, :isdst => 0, :weight_units => 'lbs', :measurement_units => 'inches')
    assert !u.valid?
    assert u.errors.on(:loginname)
  end

  def test_should_require_unique_loginname
    u = create_user(:email => 'spidahman@gmail.com', :gender => 'm', :dob => Date.today,
      :timezone => 0, :isdst => 0, :weight_units => 'lbs', :measurement_units => 'inches')
    u.update_attributes(:loginname => 'newuser')
    assert u.valid?, "#{u.errors.full_messages.to_sentence}"

    u = create_user(:email => 'spidahman@gmail.com', :gender => 'm', :dob => Date.today,
      :timezone => 0, :isdst => 0, :weight_units => 'lbs', :measurement_units => 'inches')
    u.update_attributes(:loginname => 'newuser')
    assert u.errors.on(:loginname)
  end

  def test_should_require_valid_loginname
    u = create_user(:email => 'spidahman@gmail.com', :gender => 'm', :dob => Date.today,
      :timezone => 0, :isdst => 0, :weight_units => 'lbs', :measurement_units => 'inches')
    u.update_attributes(:loginname => 'newuser!')
    assert u.errors.on(:loginname)
  end

  def test_should_require_valid_gender
    u = create_user(:loginname => 'newuser', :email => 'spidahman@gmail.com', :gender => 'a', :dob => Date.today,
      :timezone => 0, :isdst => 0, :weight_units => 'lbs', :measurement_units => 'inches')
    assert u.errors.on(:gender)

    u.update_attributes(:gender => '')
    u.reload
    assert u.valid?
    assert_equal 'm', u.gender
  end

  def test_should_require_valid_timezone
    u = create_user(:loginname => 'newuser', :email => 'spidahman@gmail.com', :gender => 'm', :dob => Date.today,
      :timezone => 7, :isdst => 0, :weight_units => 'lbs', :measurement_units => 'inches')
    assert u.errors.on(:timezone)
  end

  def test_should_require_valid_units
    u = create_user(:loginname => 'newuser', :email => 'spidahman@gmail.com', :gender => 'm', :dob => Date.today,
      :timezone => 0, :isdst => 0, :weight_units => 'a', :measurement_units => 'b')
    assert u.errors.on(:weight_units)
    assert u.errors.on(:measurement_units)
  end

  def test_should_strip_html_from_aboutme_text
    u = create_user(:loginname => 'newuser', :email => 'spidahman@gmail.com', :gender => 'm', :dob => Date.today,
      :timezone => 0, :isdst => 0, :weight_units => 'lbs', :measurement_units => 'inches')
    u.update_attributes(:profile_aboutme => 'This is just some <b>sample</b> <script type="javascript">text</script>.')
    u.reload
    assert_equal 'This is just some sample text.', u.profile_aboutme
  end

  def test_should_return_admin_pagination
    users = User.admin_pagination(1)
    assert users
    assert_equal 4, users.size

    (1..20).each { |i|
      create_user(:loginname => "newuser#{i}", :email => "spidahman#{i}@gmail.com", :gender => 'm', :dob => Date.today,
        :timezone => 0, :isdst => 0, :weight_units => 'lbs', :measurement_units => 'inches')
    }

    users = User.admin_pagination(1)
    assert users
    assert_equal 20, users.size

    users = User.admin_pagination(2)
    assert users
    assert_equal 4, users.size
  end

  def test_should_update
    u = create_user(:loginname => 'newuser', :email => 'spidahman@gmail.com', :gender => 'm', :dob => Date.today,
      :timezone => 0, :isdst => 0, :weight_units => 'lbs', :measurement_units => 'inches')
    
    assert_equal 'spidahman@gmail.com', u.email
    assert_equal 'm', u.gender
    assert_equal Date.today, u.dob
    assert_equal 0, u.timezone
    assert_equal false, u.isdst
    assert_equal 'lbs', u.weight_units
    assert_equal 'inches', u.measurement_units

    u.update_attributes(:email => 'spidah@gmail.com', :gender => 'F', :dob => Date.tomorrow, :timezone => 60, :isdst => true,
      :weight_units => 'kg', :measurement_units => 'cm')
    u.reload

    assert_equal 'spidah@gmail.com', u.email
    assert_equal 'f', u.gender
    assert_equal Date.tomorrow, u.dob
    assert_equal 60, u.timezone
    assert_equal true, u.isdst
    assert_equal 'kg', u.weight_units
    assert_equal 'cm', u.measurement_units
  end

  def test_should_return_correct_user_date
    u = create_user(:loginname => 'newuser', :email => 'spidahman@gmail.com', :gender => 'm', :dob => Date.today,
      :timezone => 0, :isdst => 0, :weight_units => 'lbs', :measurement_units => 'inches')
    assert Time.now.to_date, u.get_date

    u.update_attributes(:timezone => 780)
    u.reload
    assert_equal (Time.now + 13.hours).to_date, u.get_date
    
    u.update_attributes(:isdst => 1)
    u.reload
    assert_equal (Time.now + 13.hours + 1.hour).to_date, u.get_date

    u.update_attributes(:timezone => -720, :isdst => 0)
    u.reload
    assert_equal (Time.now - 12.hours).to_date, u.get_date
  end

  def test_cant_update_to_admin
    user = User.create(:loginname => 'newuser', :email => 'spidahman@gmail.com', :gender => 'm', :dob => Date.today,
      :time_zone => 0, :isdst => 0, :weight_units => 'lbs', :measurement_units => 'inches')
    assert !user.admin

    user.update_attributes(:admin => true)
    user.reload

    assert !user.admin
  end

  def test_should_destroy
    user = create_user(:loginname => 'newuser', :email => 'spidahman@gmail.com', :gender => 'm', :dob => Date.today,
      :timezone => 0, :isdst => 0, :weight_units => 'lbs', :measurement_units => 'inches')
    user.destroy
    assert_raise(ActiveRecord::RecordNotFound) {User.find(user.id)}
  end
end
