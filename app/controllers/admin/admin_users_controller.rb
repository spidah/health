class Admin::AdminUsersController < ApplicationController
  before_filter :admin_required
  before_filter :override_controller, :set_menu_item

  def index
    @users = User.admin_pagination(params[:page])
  end

  def edit
    begin
      @user = User.find(params[:id])
    rescue
      redirect_to admin_users_path
    end
  end

  def update
    begin
      @user = User.find(params[:id])
      @user.update_attributes(params[:user])

      redirect_to admin_users_path
    rescue
      flash[:error] = @u.errors
      render :action => 'edit'
    end
  end

  def show
    begin
      @user = User.find(params[:id])
    rescue
      redirect_to admin_users_path
    end
  end
  
  def destroy
    begin
      @user = User.find(params[:id])
      @user.destroy
    rescue
      flash[:error] = 'Unable to delete the selected user.'
    end

    redirect_to admin_users_path
  end

  protected
    def override_controller
      @overridden_controller = 'admin_users'
    end
    
    def set_menu_item
      @activemenuitem = 'menu-admin'
    end
end
