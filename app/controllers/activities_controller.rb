class ActivitiesController < ApplicationController
  before_filter :login_required, :set_menu_item

  def index
    get_all_activities
    if @activities.size == 0
      flash[:info] = 'You have not created any activities yet. You will need to add activities before you can add any exercises.'
      redirect_to(new_activity_path)
    end
  end

  def new
    new_activity
  end

  def create
    @activity = Activity.new(params[:activity])
    if @current_user.activities << @activity
      redirect_to(activities_path)
    else
      flash[:error] = @activity.errors
      render :action => 'new'
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  protected
    def get_all_activities
      @activities = @current_user.activities.pagination(params[:page], params[:sort], params[:dir] ? 'DESC' : 'ASC')
    end

    def new_activity
      @activity = Activity.new
    end

    def set_menu_item
      @activemenuitem = 'menu-exercise'
    end
end
