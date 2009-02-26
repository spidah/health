module CalendarHelper
  def month_name(date)
    date.strftime('%B %Y')
  end

  def link_month(date, text, today = nil)
    if today && date > today
      text
    else
      link_to(text, change_month_url(:date_picker => date.to_s(:db)), :class => 'change-date-link')
    end
  end

  def replace_day(date, day)
    date.beginning_of_month + day.days - 1
  end

  def link_weight(weights, date)
    if weights[date]
      link_date(date, 'weights', image_tag('weights-ball.gif', :alt => 'Weight entry', :title => 'Weight entry'))
    end
  end

  def link_measurements(measurements, date)
    if count = measurements[date]
      link_date(date, 'measurements', image_tag('measurements-ball.gif', :alt => "Measurements: #{count}", :title => "Measurements: #{count}"))
    end
  end

  def link_meals(meals, date)
    if count = meals[date]
      link_date(date, 'meals', image_tag('meals-ball.gif', :alt => "Meals: #{count}", :title => "Meals: #{count}"))
    end
  end

  def link_exercises(exercises, date)
    if count = exercises[date]
      link_date(date, 'exercises', image_tag('exercises-ball.gif', :alt => "Exercises: #{count}", :title => "Exercises: #{count}"))
    end
  end
end
