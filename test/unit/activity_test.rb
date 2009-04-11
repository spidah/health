require File.dirname(__FILE__) + '/../test_helper'

class ActivityTest < ActiveSupport::TestCase
  def setup
    @user = User.find(users(:spidah).id)
    @valid_attributes = { :name => 'Jogging', :description => 'Jogging', :type => 'Aerobic', :duration => 10, :calories => 10 }
  end

  def print_errors(activity)
    activity.errors.full_messages.to_sentence
  end

  def test_should_create
    assert_difference(Activity, :count) do
      activity = @user.activities.create(@valid_attributes)
      assert(!activity.new_record?, print_errors(activity))
    end
  end

  def test_should_require_attributes
    assert_no_difference(Activity, :count) do
      [:name, :type, :duration, :calories].each { |attribute|
        activity = @user.activities.create(@valid_attributes.except(attribute))
        assert(activity.errors.on(attribute))
      }
    end
  end

  def test_should_require_valid_attributes
    assert_no_difference(Activity, :count) do
      [:duration, :calories].each { |attribute|
        activity = @user.activities.create(@valid_attributes.merge(attribute => -1))
        assert(activity.errors.on(attribute))
      }
    end
  end

  def test_should_update
    activity = @user.activities.create(@valid_attributes)
    assert(!activity.new_record?)
    assert_equal('Jogging', activity.name)
    assert_equal('Jogging', activity.description)
    assert_equal('Aerobic', activity.type)
    assert_equal(10, activity.duration)
    assert_equal(10, activity.calories)

    activity.update_attributes(:name => 'Sprints', :description => 'Sprinting', :type => 'Anaerobic', :duration => 2, :calories => 60)
    activity.reload

    assert_equal('Sprints', activity.name)
    assert_equal('Sprinting', activity.description)
    assert_equal('Anaerobic', activity.type)
    assert_equal(2, activity.duration)
    assert_equal(60, activity.calories)
  end

  def test_should_destroy
    activity = @user.activities.create(@valid_attributes)
    activity.destroy
    assert_raise(ActiveRecord::RecordNotFound) { Activity.find(activity.id) }
  end
end
