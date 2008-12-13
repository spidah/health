class UsersController < ApplicationController
  before_filter :login_required
  before_filter :set_menu_item
  helper :measurements, :weights, :target_weights

  verify :method => :get, :only => [:index, :new, :edit, :show, :change_date], :redirect_to => 'index'
  verify :method => :post, :only => [:create], :redirect_to => 'index'
  verify :method => :put, :only => [:update], :redirect_to => 'index'
  verify :method => :delete, :only => :destroy, :redirect_to => 'index'

  def index
    @weights = @current_user.get_weights(:all, 'DESC', nil, 7)
    @target_weight = @current_user.target_weights.get_latest
    @current_weight = @current_user.weights.get_latest
    @measurements_date = @current_user.measurements.get_latest_date
    @measurements = @current_user.measurements.get_count(@measurements_date)
    @meals_date = @current_user.meals.get_latest_date
    @meals = @current_user.meals.get_count(@meals_date)
    @meals_calories = @current_user.meals.calories_for_day(@meals_date) / 100
    @exercises_date = @current_user.exercises.get_latest_date
    @exercises = @current_user.exercises.for_day(@exercises_date).get_count
    @exercises_calories = @current_user.exercises.for_day(@exercises_date).calories
    @today = @current_user.get_date
  end

  def show
    @activemenuitem = ''
    @overridden_controller = 'blank'
    if @user = User.find(:first, :conditions => {:loginname => params[:loginname]}) rescue nil
      @target_weight = @current_weight = nil
      if @user.profile_targetweight
        @target_weight = @user.target_weights.get_latest
        @current_weight = @user.weights.get_latest
      end
      @current_weight = @user.weights.get_latest if @user.profile_weights
      @measurements = @user.measurements.get_latest_measurements if @user.profile_measurements
    else
      redirect_to dashboard_path
    end
  end

  def edit
    @user = @current_user
    @openid_links = UserLogin.find_openid_login(@current_user)
  end

  def update
    if params[:current_password] && !params[:current_password].blank?
      ul = UserLogin.find_normal_login(@current_user)
      if ul.authenticated?(params[:current_password])
        ul.password = params[:new_password]
        ul.password_confirmation = params[:confirm_password]
        if ul.save
          successful_update('Your password has been updated.')
        else
          failed_update(ul.errors)
        end
      else
        failed_update('You did not enter your current password, please try again.')
      end
      return
    end

    if @current_user.update_attributes(params[:user])
      successful_update('Your settings have been updated.')
    else
      failed_update(@current_user.errors)
    end
  end

  def change_date
    session[:displaydate] = Date.parse(params[:date_picker]) rescue session[:displaydate]

    redirect_to request.referer || dashboard_path
  end

  protected
    def set_menu_item
      @activemenuitem = 'menu-account'
    end

    def failed_update(message)
      flash[:error] = message
      redirect_to(edit_user_path)
    end

    def successful_update(message)
      flash[:info] = message
      redirect_to(edit_user_path)
    end
end
