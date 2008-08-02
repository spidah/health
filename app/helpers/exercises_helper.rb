module ExercisesHelper
  def activities_to_options(activities, id)
    activities.collect {|activity| "<option value=\"#{activity.id}\"#{"selected=\"selected\"" if id == activity.id}>#{activity.name}#{' - ' + activity.description if !activity.description.blank?}</option>"}
  end
end
