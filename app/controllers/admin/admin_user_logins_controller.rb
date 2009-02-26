class Admin::AdminUserLoginsController < ApplicationController
  before_filter :admin_required
  before_filter :override_controller, :set_menu_item

  def index
    @user_logins = UserLogin.admin_pagination(params[:page])
  end

  def show
    @user_login = UserLogin.find(params[:id])
  rescue
    redirect_to(admin_user_logins_url)
  end

  def edit
    @user_login = UserLogin.find(params[:id], :include => :user)
  rescue
    redirect_to(admin_user_logins_url)
  end

  def update
    @user_login = UserLogin.find(params[:id])

    if params[:password]
      @user_login.password = params[:password]
      @user_login.password_confirmation = params[:password_confirmation]
    end

    if @user_login.update_attributes(params[:user_login])
      flash[:info] = 'The user login details were updated successfully.'
      redirect_to(admin_user_logins_url)
    else
      flash[:error] = @user_login.errors
      render(:action => 'edit')
    end
  end

  def destroy
    @user_login = UserLogin.find(params[:id])
    @user_login.destroy
    flash[:info] = 'The user login details were deleted successfully.'
  rescue
    flash[:error] = 'Unable to delete the selected OpenID link.'
  ensure
    redirect_to(admin_user_logins_url)
  end

  protected

  def override_controller
    @overridden_controller = 'admin_user_logins'
  end

  def set_menu_item
    @activemenuitem = 'menu-account'
  end
end
