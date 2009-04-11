require File.dirname(__FILE__) + '/../test_helper'

class ExerciseTest < ActiveSupport::TestCase
  def setup
    @user = User.find(users(:bob).id)
    @activity = Activity.find(activities(:jogging).id)
  end

  def print_errors(exercise)
    exercise.errors.full_messages.to_sentence
  end

  def test_should_create
    assert_difference(Exercise, :count) do
      exercise = @user.exercises.new
      exercise.set_values(10, @activity)

      assert(exercise.valid?, print_errors(exercise))
      assert(exercise.save)
      assert(!exercise.new_record?, print_errors(exercise))
    end
  end

  def test_should_require_duration
    assert_no_difference(Exercise, :count) do
      exercise = @user.exercises.new
      exercise.set_values('', @activity)

      assert(!exercise.valid?)
      assert(exercise.errors.on(:duration))
      assert_equal('Please enter a duration greater than 0.', exercise.errors.on(:duration))
    end
  end

  def test_should_require_valid_duration
    assert_no_difference(Exercise, :count) do
      exercise = @user.exercises.new
      exercise.set_values(-1, @activity)

      assert(!exercise.valid?)
      assert(exercise.errors.on(:duration))
      assert_equal('Please enter a duration greater than 0.', exercise.errors.on(:duration))
    end
  end

  def test_should_update
    exercise = @user.exercises.new
    exercise.set_values(10, @activity)
    exercise.save

    assert_equal(10, exercise.duration)

    exercise.update_attributes(:duration => 20)
    exercise.reload

    assert_equal(20, exercise.duration)
  end

  def test_should_destroy
    exercise = @user.exercises.new
    exercise.set_values(10, @activity)
    exercise.save

    exercise.destroy
    assert_raise(ActiveRecord::RecordNotFound) { Exercise.find(exercise.id) }
  end
end
