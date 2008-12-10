class ExercisesController < ApplicationController
  before_filter :login_required, :set_menu_item

  verify :method => :get, :only => [:index, :new, :edit], :redirect_to => 'index'
  verify :method => :post, :only => :create, :redirect_to => 'index'
  verify :method => :put, :only => :update, :redirect_to => 'index'
  verify :method => :delete, :only => :destroy, :redirect_to => 'index'

  def index
    get_all_exercises
    get_totals
  end

  def new
    new_exercise
    get_all_activities
  end

  def create
    e_params = params[:exercise]
    @exercise = Exercise.new

    if !@activity = @current_user.activities.find(e_params["activity"])
      flash[:error] = 'Unable to add the selected activity'
      render(:action => 'new') and return
    end

    @exercise.taken_on = current_date
    @exercise.set_values(e_params, @activity)

    if @current_user.exercises << @exercise
      redirect_to(exercises_path)
    else
      flash[:error] = @exercise.errors
      render(:action => 'new')
    end
  end

  def edit
    @exercise = @current_user.exercises.find(params[:id])
    get_all_activities
  rescue
    flash[:error] = 'Unable to edit the selected exercise.'
    redirect_to(exercises_path)
  end

  def update
    begin
      @exercise = @current_user.exercises.find(params[:id])
    rescue
      flash[:error] = 'Unable to update the selected exercise.'
      redirect_to(exercises_path) and return
    end

    e_params = params[:exercise]

    if !@activity = @current_user.activities.find(e_params["activity"])
      flash[:error] = 'Unable to add the selected activity'
      render(:action => 'new') and return
    end

    @exercise.set_values(e_params, @activity)
    if !@exercise.save
      flash[:error] = @exercise.errors
    end
    redirect_to(exercises_path)
  end

  def destroy
    begin
      @exercise = @current_user.exercises.find(params[:id])
      @exercise.destroy
    rescue
      flash[:error] = 'Unable to delete the selected exercise.'
    end
    redirect_to(exercises_path)
  end

  protected
    def get_all_exercises
      @exercises = @current_user.exercises.find_for_day(current_date)
    end

    def get_all_activities
      @activities = @current_user.activities.find(:all)
    end

    def get_totals
      @total_duration = @current_user.exercises.duration_for_day(current_date)
      @total_calories = @current_user.exercises.calories_for_day(current_date)
    end

    def new_exercise
      @exercise = Exercise.new
    end

    def set_menu_item
      @activemenuitem = 'menu-exercise'
    end
end
