class ActivitiesController < ApplicationController
  before_filter :login_required, :set_menu_item

  verify :method => :get, :only => [:index, :new, :edit], :redirect_to => 'index'
  verify :method => :post, :only => :create, :redirect_to => 'index'
  verify :method => :put, :only => :update, :redirect_to => 'index'
  verify :method => :delete, :only => :destroy, :redirect_to => 'index'

  def index
    get_all_activities
    if @activities.size == 0
      flash[:info] = 'You have not created any activities yet. You will need to add activities before you can add any exercises.'
      redirect_to(new_activity_path)
    end
  end

  def new
    @activity = Activity.new
  end

  def create
    @activity = @current_user.activities.build(params[:activity])
    @activity.save!
    redirect_to(activities_path)
  rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
    flash[:error] = @activity.errors
    redirect_to(new_activity_path)
  end

  def edit
    @activity = @current_user.activities.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Unable to edit the selected activity.'
    redirect_to(activities_path)
  end

  def update
    begin
      @activity = @current_user.activities.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = 'Unable to update the selected activity.'
      redirect_to(activities_path) and return
    end

    begin
      @activity.update_attributes!(params[:activity])
      redirect_to(activities_path)
    rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
      flash[:error] = @activity.errors
      redirect_to(edit_activity_path(@activity))
    end
  end

  def destroy
    @activity = @current_user.activities.find(params[:id])
    @activity.destroy
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Unable to delete the selected activity.'
  ensure
    redirect_to(activities_path)
  end

  protected

  def get_all_activities
    @activities = @current_user.activities.pagination(params[:page], params[:sort], params[:dir] ? 'DESC' : 'ASC')
  end

  def set_menu_item
    @activemenuitem = 'menu-exercise'
  end
end
