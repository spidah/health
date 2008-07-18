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
    @weights = Weight.get_count(date)
    @measurements = Measurement.get_count(date)
    @meals = Meal.get_count(date)
    # @exercises = Exercise.get_count(date)
  end
end
