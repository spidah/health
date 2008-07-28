class UsersController < ApplicationController
  before_filter :login_required
  before_filter :set_menu_item
  helper :measurements, :weights, :target_weights

  def index
    @measurements = @current_user.measurements.get_latest_measurements
    @measurements_date = @measurements[0].taken_on if @measurements.size > 0
    @weights = @current_user.get_weights(:all, 'DESC', nil, 7)
    @target_weight = @current_user.target_weights.get_latest
    @current_weight = @current_user.weights.get_latest
    @today = @current_user.get_date
  end

  def show
    @activemenuitem = ''
    @overridden_controller = 'blank'
    if @user = User.find(:first, :conditions => {:loginname => params[:loginname]}) rescue nil
      if @user.profile_targetweight
        @target_weight = @user.target_weights.get_latest
        @current_weight = @user.weights.get_latest
      end
      @weight = @user.weights.get_latest if @user.profile_weights
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
