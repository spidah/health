require "#{File.dirname(__FILE__)}/../test_helper"

class IntegrationExercisesTest < ActionController::IntegrationTest
  def test_exercises
    spidah = new_session_as(:spidah)
    spidah.login

    spidah.should_have_no_activities
    spidah.should_not_add_invalid_activity
    spidah.should_add_valid_activity('Jogging', 'Jogging around the park', 'Aerobic', 10, 30)
    jogging = spidah.add_activity('Jogging', 'Jogging around the park', 'Aerobic', 10, 30)
    spidah.should_have_activities(1)
    spidah.should_not_edit_invalid_activity
    spidah.should_not_update_invalid_activity
    spidah.should_not_update_activity_with_invalid_attributes(jogging)
    spidah.should_update_activity(jogging, 'Sprinting', 'Sprinting around the park', 'Anaerobic', 20, 90)
    spidah.should_not_delete_invalid_activity
    spidah.should_delete_activity(jogging)

    jogging_a = spidah.add_activity('Jogging', 'Jogging around the park', 'Aerobic', 10, 30)
    walking_a = spidah.add_activity('Walking', 'Walking around the park', 'Aerobic', 10, 10)

    spidah.change_date(Date.today)
    spidah.should_have_no_exercises
    spidah.should_not_add_exercise_for_invalid_activity
    spidah.should_not_add_exercise_with_invalid_attributes(jogging_a)
    spidah.should_add_exercise_for_valid_activity(jogging_a, 30, 90)
    jogging_e = spidah.add_exercise(jogging_a, 30)
    spidah.should_list_exercise(jogging_a.name, jogging_e.duration, jogging_e.calories)
    walking_e = spidah.add_exercise(walking_a, 40)
    spidah.should_list_exercise(walking_a.name, walking_e.duration, walking_e.calories)
    spidah.should_have_exercise_totals(70, 130)
    spidah.should_not_edit_invalid_exercise
    spidah.should_not_update_invalid_exercise
    spidah.should_not_update_exercise_with_invalid_activity(jogging_e)
    spidah.should_not_update_exercise_with_invalid_attributes(jogging_e)
    spidah.should_not_delete_invalid_exercise
    spidah.should_delete_exercise(jogging_e)
    spidah.delete_exercise(walking_e)

    jogging_e = spidah.add_exercise(jogging_a, 30)
    spidah.should_have_exercises(1)
    spidah.change_date(Date.tomorrow)
    spidah.should_have_no_exercises
    spidah.add_exercise(jogging_a, 30)
    spidah.add_exercise(jogging_a, 40)
    spidah.should_have_exercises(2)

    bob = new_session_as(:bob)
    bob.login
    bob.add_activity('Jogging', 'Jogging', 'Aerobic', 10, 30)
    bob.should_not_edit_another_users_activity(jogging)
    bob.should_not_update_another_users_activity(jogging)
    bob.should_not_delete_another_users_activity(jogging)
    bob.should_not_edit_another_users_exercise(jogging_e)
    bob.should_not_update_another_users_exercise(jogging_e)
    bob.should_not_delete_another_users_exercise(jogging_e)
  end

  module ExercisesTestDSL
    attr_accessor :user, :user_login

    def login
      $mockuser = user
      post(session_path, :openid_url => user_login.openid_url)
      get(open_id_complete_path, :openid_url => user_login.openid_url, :open_id_complete => 1)
      assert_dashboard_redirect
    end

    def change_date(date)
      post(change_date_path, {:date_picker => format_date(date)})

      assert_response(:redirect)
      follow_redirect!
      assert_response(:success)

      assert_select('a', format_date(date))
    end

    def assert_activity_values(activity, name, description, type, duration, calories)
      get(edit_activity_path(activity))
      assert_success('activities/edit')
      assert_no_flash('error')
      assert_select('input[id=activity_name][value=?]', name)
      assert_select('input[id=activity_description][value=?]', description)
      assert_select('option[selected=selected]', type)
      assert_select('input[id=activity_duration][value=?]', duration)
      assert_select('input[id=activity_calories][value=?]', calories)
    end

    def activity_exists(activity)
      Activity.exists?(activity.id)
    end

    def exercise_exists(exercise)
      Exercise.exists?(exercise.id)
    end

    def add_activity(name, description, type, duration, calories)
      post(activities_path, :activity => {:name => name, :description => description, :type => type, :duration => duration, :calories => calories})
      return user.activities.find(:first, :order => 'id DESC')
    end

    def should_have_no_activities
      get(activities_path)
      assert_and_follow_redirect(new_activity_path, 'activities/new')
      assert_flash('info')
    end

    def should_have_activities(count)
      get(activities_path)
      assert_success('activities/index')
      assert_no_flash('info')
      assert_no_flash('error')
      assert_select('table[class=activities-list]', 1) do
        assert_select('tr[class=?]', /(odd|even)/, count)
      end
    end

    def should_not_add_invalid_activity
      post(activities_path, :activity => {:name => '', :description => '', :type => '', :duration => '', :calories => ''})
      assert_and_follow_redirect(new_activity_path, 'activities/new')
      assert_flash('error', nil, 'Error saving activity')
      assert_flash_item('error', 'Please enter a name for the activity.')
      assert_flash_item('error', 'Please select a type for the activity.')
      assert_flash_item('error', 'Please enter a duration for the activity.')
      assert_flash_item('error', 'Please enter the calories for the activity.')

      post(activities_path, :activity => {:name => 'a', :description => 'a', :type => 'a', :duration => -1, :calories => -1})
      assert_and_follow_redirect(new_activity_path, 'activities/new')
      assert_flash('error', nil, 'Error saving activity')
      assert_flash_item('error', 'Please enter a valid duration for the activity.')
      assert_flash_item('error', 'Please enter a valid calorie count for the activity.')
    end

    def should_add_valid_activity(name, description, type, duration, calories)
      activity = add_activity(name, description, type, duration, calories)

      assert_not_nil(activity)
      assert_equal(name, activity.name)
      assert_equal(description, activity.description)
      assert_equal(type, activity.type)
      assert_equal(duration, activity.duration)
      assert_equal(calories, activity.calories)

      delete_activity(activity)
    end

    def should_not_edit_invalid_activity
      get(edit_activity_path(10000))
      assert_and_follow_redirect(activities_path, 'activities/index')
      assert_flash('error', 'Unable to edit the selected activity.')
    end

    def should_update_activity(activity, name, description, type, duration, calories)
      assert_activity_values(activity, activity.name, activity.description, activity.type, activity.duration, activity.calories)

      put(activity_path(activity), :activity => {:name => name, :description => description, :type => type, :duration => duration, :calories => calories})
      assert_activity_values(activity, name, description, type, duration, calories)
    end

    def should_not_update_activity_with_invalid_attributes(activity)
      put(activity_path(activity), :activity => {:name => '', :description => '', :type => '', :duration => '', :calories => ''})
      assert_and_follow_redirect(edit_activity_path(activity), 'activities/edit')
      assert_flash('error', nil, 'Error saving activity')
      assert_flash_item('error', 'Please enter a name for the activity.')
      assert_flash_item('error', 'Please select a type for the activity.')
      assert_flash_item('error', 'Please enter a duration for the activity.')
      assert_flash_item('error', 'Please enter the calories for the activity.')
    end

    def should_not_update_invalid_activity
      put(activity_path(10000), :activity => {:name => 'a', :description => 'a', :type => 'a', :duration => 1, :calories => 1})
      assert_and_follow_redirect(activities_path, 'activities/index')
      assert_flash('error', 'Unable to update the selected activity.')
    end

    def delete_activity(activity)
      delete(activity_path(activity))
    end

    def should_not_delete_invalid_activity
      delete_activity(10000)
      assert_and_follow_redirect(activities_path, 'activities/index')
      assert_flash('error', 'Unable to delete the selected activity.')
    end

    def should_delete_activity(activity)
      assert(activity_exists(activity))
      delete_activity(activity)
      assert(!activity_exists(activity))
    end

    def should_have_no_exercises
      get(exercises_path)
      assert_select('p', 'You have not entered any exercises for today.')
    end

    def should_have_exercises(count)
      get(exercises_path)
      assert_success('exercises/index')
      assert_no_flash('info')
      assert_no_flash('error')
      assert_select('table[class=exercises-list]', 1) do
        assert_select('tr', count + 2)
      end
    end

    def should_list_exercise(name, duration, calories)
      get(exercises_path)
      assert_select('tr[class=exercise-item]') do
        assert_select('td', name)
        assert_select('td[class*=duration]', /#{duration}/)
        assert_select('td[class*=calories]', calories.to_s)
      end
    end

    def should_have_exercise_totals(duration, calories)
      get(exercises_path)
      assert_select('tr[class=exercise-totals]') do
        assert_select('td[class*=duration]', /#{duration}/)
        assert_select('td[class*=calories]', calories.to_s)
      end
    end

    def should_not_add_exercise_for_invalid_activity
      post(exercises_path, :exercise => {:activity => 10000, :duration => 10})
      assert_and_follow_redirect(new_exercise_path, 'exercises/new')
      assert_flash('error', 'Unable to add the selected activity.')
    end

    def should_not_add_exercise_with_invalid_attributes(activity)
      post(exercises_path, :exercise => {:activity => activity.id, :duration => 0})
      assert_and_follow_redirect(new_exercise_path, 'exercises/new')
      assert_flash_item('error', 'Please enter a duration greater than 0.')
    end

    def add_exercise(activity, duration)
      post(exercises_path, :exercise => {:activity => activity.id, :duration => duration})
      return user.exercises.find(:first, :order => 'id DESC')
    end

    def should_add_exercise_for_valid_activity(activity, duration, expected_calories)
      exercise = add_exercise(activity, duration)
      assert_and_follow_redirect(exercises_path, 'exercises/index')
      assert_select('tr') do
        assert_select('td', activity.name)
        assert_select('td[class*=number]', expected_calories.to_s)
      end
      delete_exercise(exercise)
    end

    def delete_exercise(exercise)
      delete(exercise_path(exercise))
    end

    def should_delete_exercise(exercise)
      assert(exercise_exists(exercise))
      delete_exercise(exercise)
      assert(!exercise_exists(exercise))
    end

    def should_not_delete_invalid_exercise
      delete_exercise(10000)
      assert_and_follow_redirect(exercises_path, 'exercises/index')
      assert_flash('error', 'Unable to delete the selected exercise.')
    end

    def should_not_edit_invalid_exercise
      get(edit_exercise_path(10000))
      assert_and_follow_redirect(exercises_path, 'exercises/index')
      assert_flash('error', 'Unable to edit the selected exercise.')
    end

    def should_not_update_invalid_exercise
      put(exercise_path(10000))
      assert_and_follow_redirect(exercises_path, 'exercises/index')
      assert_flash('error', 'Unable to update the selected exercise.')
    end

    def should_not_update_exercise_with_invalid_activity(exercise)
      put(exercise_path(exercise), :exercise => {:activity => 10000, :duration => 1})
      assert_and_follow_redirect(edit_exercise_path(exercise), 'exercises/edit')
      assert_flash('error', 'Unable to find the selected activity.')
    end

    def should_not_update_exercise_with_invalid_attributes(exercise)
      put(exercise_path(exercise), :exercise => {:activity => exercise.activity_id, :duration => -1})
      assert_and_follow_redirect(edit_exercise_path(exercise), 'exercises/edit')
      assert_flash_item('error', 'Please enter a duration greater than 0.')
    end

    def should_not_edit_another_users_activity(activity)
      get(edit_activity_path(activity))
      assert_and_follow_redirect(activities_path, 'activities/index')
      assert_flash('error', 'Unable to edit the selected activity.')
    end

    def should_not_update_another_users_activity(activity)
      put(activity_path(activity))
      assert_and_follow_redirect(activities_path, 'activities/index')
      assert_flash('error', 'Unable to update the selected activity.')
    end

    def should_not_delete_another_users_activity(activity)
      delete(activity_path(activity))
      assert_and_follow_redirect(activities_path, 'activities/index')
      assert_flash('error', 'Unable to delete the selected activity.')
    end

    def should_not_edit_another_users_exercise(exercise)
      get(edit_exercise_path(exercise))
      assert_and_follow_redirect(exercises_path, 'exercises/index')
      assert_flash('error', 'Unable to edit the selected exercise.')
    end

    def should_not_update_another_users_exercise(exercise)
      put(exercise_path(exercise))
      assert_and_follow_redirect(exercises_path, 'exercises/index')
      assert_flash('error', 'Unable to update the selected exercise.')
    end

    def should_not_delete_another_users_exercise(exercise)
      delete(exercise_path(exercise))
      assert_and_follow_redirect(exercises_path, 'exercises/index')
      assert_flash('error', 'Unable to delete the selected exercise.')
    end
  end

  def new_session_as(user)
    open_session do |session|
      session.extend(ExercisesTestDSL)
      session.user = get_user(users(user))
      session.user_login = user_logins(user)
      yield session if block_given?
    end
  end
end
