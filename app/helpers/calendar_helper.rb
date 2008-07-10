module CalendarHelper
  def month_name(date)
    date.strftime('%B')
  end
end
