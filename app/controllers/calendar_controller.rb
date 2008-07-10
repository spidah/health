class CalendarController < ApplicationController
  before_filter :login_required, :set_menu_item
  before_filter :include_stylesheet

  def show
    @date = current_date
    @weekday = convert_week_day_number(@date.wday)
    @monthstart = convert_week_day_number(@date.beginning_of_month.wday)
    logger.warn "@monthstart: #{@monthstart}"
    @monthdays = @date.end_of_month.day
    @monthend = convert_week_day_number(@date.end_of_month.wday)
    @prevmonth = @date - 1.month
    @nextmonth = @date + 1.month
    @dayindex = 1
    @weekindex = 1
  end

  protected
    def convert_week_day_number(wday)
      wday > 0 ? wday : 7
    end

    def set_menu_item
      @activemenuitem = 'menu-account'
    end

    def include_stylesheet
      include_extra_stylesheet :mycalendar
    end
end
