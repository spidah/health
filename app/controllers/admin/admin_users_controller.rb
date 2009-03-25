class Admin::AdminUsersController < ApplicationController
  before_filter :admin_required
  before_filter :override_controller, :set_menu_item
  before_filter :admin_get_user, :only => [:show, :edit, :update, :destroy]
  before_filter :check_cancel, :only => [:update, :destroy]

  def index
    @users = User.admin_pagination(params[:page])
  end

  def show
  end

  def edit
  end

  def update
    @user.update_attributes!(params[:user])
    redirect_to(admin_users_url)
  rescue
    flash[:error] = @user.errors
    render(:action => 'edit')
  end

  def destroy
    if request.delete?
      @user.destroy
      redirect_to(admin_users_url)
    end
  end

  protected

  def override_controller
    @overridden_controller = 'admin_users'
  end

  def set_menu_item
    @activemenuitem = 'menu-account'
  end

  def admin_get_user
    @user = User.find(params[:id].to_i)
  rescue
    redirect_to(admin_users_url)
  end

  def check_cancel
    redirect_to(admin_users_url) if params[:cancel]
  end
end
