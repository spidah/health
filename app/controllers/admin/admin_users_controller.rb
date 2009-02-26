class Admin::AdminUsersController < ApplicationController
  before_filter :admin_required
  before_filter :override_controller, :set_menu_item

  def index
    @users = User.admin_pagination(params[:page])
  end

  def edit
    @user = User.find(params[:id])
  rescue
    redirect_to(admin_users_url)
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])

    redirect_to(admin_users_url)
  rescue
    flash[:error] = @user.errors
    render(:action => 'edit')
  end

  def show
    @user = User.find(params[:id])
  rescue
    redirect_to(admin_users_url)
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
  rescue
    flash[:error] = 'Unable to delete the selected user.'
  ensure
    redirect_to(admin_users_url)
  end

  protected

  def override_controller
    @overridden_controller = 'admin_users'
  end

  def set_menu_item
    @activemenuitem = 'menu-account'
  end
end
