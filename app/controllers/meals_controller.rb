class MealsController < ApplicationController
  before_filter :login_required, :set_menu_item

  verify :method => :get, :only => [:index, :new, :edit, :show], :redirect_to => 'index'
  verify :method => :post, :only => [:create], :redirect_to => 'index'
  verify :method => :delete, :only => :destroy, :redirect_to => 'index'

  def index
    @meals = @current_user.meals.find_for_day(current_date)
  end

  def show
    @meal = @current_user.meals.find(params[:id].to_i)
    redirect_to new_meal_food_item_path(@meal) and return if @meal.food_items.size == 0
  rescue
    flash[:error] = 'Unable to display the selected meal.'
    redirect_to meals_path
  end

  def new
    @meal = Meal.new
  end

  def create
    @meal = Meal.new(params[:meal])
    if @current_user.meals << @meal
      redirect_to meal_path(@meal)
    else
      flash[:error] = @meal.errors
      render :action => 'new'
    end
  end

  def destroy
    begin
      @meal = @current_user.meals.find(params[:id].to_i)
      @meal.destroy
    rescue
      flash[:error] = 'Unable to delete the selected meal.'
    end
    redirect_to meals_path
  end

  def edit
    @meal = @current_user.meals.find(params[:id].to_i)
  rescue
    flash[:error] = 'Unable to edit the selected meal.'
    redirect_to meals_path
  end

  protected
    def set_menu_item
      @activemenuitem = 'menu-meals'
    end
end
