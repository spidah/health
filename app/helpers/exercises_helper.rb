module ExercisesHelper
  def activities_to_options(activities, id)
    activities.collect {|activity| "<option value=\"#{activity.id}\"#{"selected=\"selected\"" if id == activity.id}>#{activity.name} - #{pluralize(activity.duration, 'minute')} - #{pluralize(activity.calories, 'calorie')}</option>"}
  end
end
