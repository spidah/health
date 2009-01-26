class CalendarController < ApplicationController
  before_filter :login_required, :set_menu_item
  before_filter :include_stylesheet

  def show
    @usertoday = @current_user.get_date
    @today = current_date
    @date = session[:calendar_date] || @today
    @weekday = convert_week_day_number(@date.wday)
    @monthstart = convert_week_day_number(@date.beginning_of_month.wday)
    @monthdays = @date.end_of_month.day
    @monthend = convert_week_day_number(@date.end_of_month.wday)
    @prevmonth = @date - 1.month
    @nextmonth = @date + 1.month
    @dayindex = 1
    @weekindex = 1
    @weights = @current_user.weights.for_month(@date).counts
    @measurements = @current_user.measurements.for_month(@date).counts
    @meals = @current_user.meals.for_month(@date).counts
    @exercises = @current_user.exercises.for_month(@date).counts
  end

  def change_date
    session[:displaydate] = Date.parse(params[:date_picker]) rescue session[:displaydate]
    session[:calendar_date] = nil

    session[:displaydate] = @current_user.get_date if session[:displaydate] > @current_user.get_date

    @current_user.weights.cache_existing_weight(session, current_date)

    redirect_path = eval("#{params[:section]}_path") rescue dashboard_path
    redirect_to redirect_path
  end

  def change_month
    session[:calendar_date] = Date.parse(params[:date_picker]) rescue session[:displaydate]
    session[:calendar_date] = @current_user.get_date if session[:calendar_date] > @current_user.get_date
    redirect_to calendar_path
  end

  protected
    def convert_week_day_number(wday)
      wday > 0 ? wday : 7
    end

    def set_menu_item
      @activemenuitem = 'menu-account'
    end

    def include_stylesheet
      include_extra_stylesheet :calendar
    end
end
