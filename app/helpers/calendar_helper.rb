module CalendarHelper
  def month_name(date)
    date.strftime('%B')
  end
  
  def link_month(date, text)
    link_to(text, change_month_path(:date_picker => date.to_s(:db)), :class => 'change-date-link')
  end

  def replace_day(date, day)
    date.beginning_of_month + day.days - 1
  end

  def day_counts(date)
    @weights_count = @current_user.weights.get_count(date)
    @measurements_count = @current_user.measurements.get_count(date)
    @meals_count = @current_user.meals.for_day(date).get_count
    @exercises_count = @current_user.exercises.for_day(date).get_count
  end
end
