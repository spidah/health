require File.dirname(__FILE__) + '/../test_helper'

class MeasurementTest < Test::Unit::TestCase
  fixtures :users, :measurements

  def setup
    @user = User.find(users(:spidah).id)
  end

  def create_measurement(taken_on = nil, measurement = nil, location = nil)
    m = Measurement.new(:taken_on => taken_on, :measurement => measurement, :location => location)
    @user.measurements << m
    m
  end

  def test_should_create_measurement
    assert_difference Measurement, :count do
      m = create_measurement(Date.today, 10, 'Left leg')
      assert !m.new_record?, "#{m.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_taken_on
    assert_no_difference Measurement, :count do
      m = create_measurement(nil, 10, 'Left leg')
      assert m.errors.on(:taken_on)
    end
  end

  def test_should_require_measurement
    assert_no_difference Measurement, :count do
      m = create_measurement(Date.today, nil, 'Left leg')
      assert m.errors.on(:measurement)
    end
  end

  def test_should_require_location
    assert_no_difference Measurement, :count do
      m = create_measurement(nil, 10, nil)
      assert m.errors.on(:location)
    end
  end

  def test_should_require_valid_measurement
    assert_no_difference Measurement, :count do
      m = create_measurement(Date.today, -10, 'Left leg')
      assert m.errors.on(:measurement)
    end

    assert_no_difference Measurement, :count do
      m = create_measurement(Date.today, 'a', 'Left leg')
      assert m.errors.on(:measurement)
    end
  end

  def test_should_require_unique_location
    assert_difference Measurement, :count do
      m = create_measurement(Date.today, 10, 'Left leg')
    end
    
    assert_no_difference Measurement, :count do
      m = create_measurement(Date.today, 20, 'Left leg')
      assert m.errors.on(:location)
    end
  end

  def test_should_capitalise_location
    assert_difference Measurement, :count do
      m = create_measurement(Date.today, 10, 'left leg')
      assert 'Left leg', m.location
    end
  end

  def test_should_update_difference
    m1 = create_measurement(Date.today, 10, 'Left leg')
    m2 = create_measurement(m1.taken_on + 1.day, 20, 'Left leg')
    m3 = create_measurement(m2.taken_on + 2.days, 15, 'Left leg')
    assert_equal 0, m1.difference
    assert_equal 10, m2.difference
    assert_equal -5, m3.difference
    m4 = create_measurement(m1.taken_on - 1.day, 8, 'Left leg')
    m1.reload
    assert_equal 2, m1.difference
    m2.destroy
    m3.reload
    assert_equal 5, m3.difference
    m1.destroy
    m3.reload
    assert_equal 7, m3.difference
  end

  def test_should_update_difference_with_location_change
    m1 = create_measurement(Date.today, 10, 'Left leg')
    m2 = create_measurement(m1.taken_on + 1.day, 15, 'Left leg')
    m3 = create_measurement(m2.taken_on + 1.day, 20, 'Left leg')
    assert_equal 0, m1.difference
    assert_equal 5, m2.difference
    assert_equal 5, m3.difference

    m1.reload
    m2.reload
    m3.reload

    m2.update_attributes(:location => 'Right leg')
    m3.reload
    assert_equal 10, m3.difference

    m1.update_attributes(:location => 'Right leg')
    m3.reload
    assert_equal 0, m3.difference

    m2.reload
    assert_equal 5, m2.difference
  end

  def test_should_update
    m = create_measurement(Date.today, 10, 'Left leg')
    assert_equal Date.today, m.taken_on
    assert_equal 10, m.measurement
    assert_equal 'Left leg', m.location
    m.update_attributes(:taken_on => Date.today + 1.day, :measurement => 20, :location => 'Right arm')
    m.reload
    assert_equal Date.today + 1.day, m.taken_on
    assert_equal 20, m.measurement
    assert_equal 'Right arm', m.location
  end

  def test_should_destroy
    m = create_measurement(Date.today, 10, 'Left leg')
    m.destroy
    assert_raise(ActiveRecord::RecordNotFound) {Measurement.find(m.id)}
  end
end
