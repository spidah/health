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
    @exercise = Exercise.new
    get_all_activities
  end

  def create
    begin
      @activity = @current_user.activities.find(params[:exercise]["activity"])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = 'Unable to add the selected activity.'
      redirect_to(new_exercise_path) and return
    end

    @exercise = @current_user.exercises.build
    @exercise.taken_on = current_date
    @exercise.set_values(params[:exercise]["duration"], @activity)

    begin
      @exercise.save!
      redirect_to(exercises_path)
    rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
      flash[:error] = @exercise.errors
      redirect_to(new_exercise_path)
    end
  end

  def edit
    @exercise = @current_user.exercises.find(params[:id])
    get_all_activities
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Unable to edit the selected exercise.'
    redirect_to(exercises_path)
  end

  def update
    begin
      @exercise = @current_user.exercises.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = 'Unable to update the selected exercise.'
      redirect_to(exercises_path) and return
    end

    begin
      @activity = @current_user.activities.find(params[:exercise]["activity"])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = 'Unable to find the selected activity.'
      redirect_to(edit_exercise_path(@exercise)) and return
    end

    @exercise.set_values(params[:exercise]["duration"], @activity)

    begin
      @exercise.save!
      redirect_to(exercises_path)
    rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
      flash[:error] = @exercise.errors
      redirect_to(edit_exercise_path(@exercise))
    end
  end

  def destroy
    @exercise = @current_user.exercises.find(params[:id])
    @exercise.destroy
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Unable to delete the selected exercise.'
  ensure
    redirect_to(exercises_path)
  end

  protected
  def get_all_exercises
    @exercises = @current_user.exercises.for_day(current_date)
  end

  def get_all_activities
    @activities = @current_user.activities.find(:all)
  end

  def get_totals
    @total_duration = @current_user.exercises.for_day(current_date).duration
    @total_calories = @current_user.exercises.for_day(current_date).calories
  end

  def set_menu_item
    @activemenuitem = 'menu-exercise'
  end
end
