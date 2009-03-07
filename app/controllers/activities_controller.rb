class ActivitiesController < ApplicationController
  before_filter :login_required, :set_menu_item
  before_filter :get_activity, :only => [:edit, :update, :destroy]

  verify :method => :get, :only => [:index, :new, :edit], :redirect_to => 'index'
  verify :method => :post, :only => :create, :redirect_to => 'index'
  verify :method => :put, :only => :update, :redirect_to => 'index'
  verify :method => [:get, :delete], :only => :destroy, :redirect_to => 'index'

  def index
    get_all_activities
    if @activities.size == 0
      flash[:info] = 'You have not created any activities yet. You will need to add activities before you can add any exercises.'
      redirect_to(new_activity_url)
    end
  end

  def new
    @activity = Activity.new
  end

  def create
    @activity = @current_user.activities.build(params[:activity])
    @activity.save!
    redirect_to(activities_url)
  rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
    flash[:error] = @activity.errors
    redirect_to(new_activity_url)
  end

  def edit
  end

  def update
    @activity.update_attributes!(params[:activity])
    redirect_to(activities_url)
  rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
    flash[:error] = @activity.errors
    redirect_to(edit_activity_url(@activity))
  end

  def destroy
    if request.delete?
      begin
        @activity.destroy
      rescue ActiveRecord::RecordNotFound
        flash[:error] = 'Unable to delete the selected activity.'
      ensure
        redirect_to(activities_url)
      end
    end
  end

  protected

  def get_all_activities
    @activities = @current_user.activities.pagination(params[:page], params[:sort], params[:dir] ? 'DESC' : 'ASC')
  end

  def get_activity
    @activity = @current_user.activities.find(params[:id].to_i)
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Unable to find the selected activity.'
    redirect_to(activities_url)
  end

  def set_menu_item
    @activemenuitem = 'menu-exercise'
  end
end
