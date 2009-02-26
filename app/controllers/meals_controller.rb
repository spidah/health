class MealsController < ApplicationController
  before_filter :login_required, :set_menu_item, :include_meal_files

  verify :method => :get, :only => [:index, :new, :edit, :show], :redirect_to => 'index'
  verify :method => :post, :only => [:create], :redirect_to => 'index'
  verify :method => :delete, :only => :destroy, :redirect_to => 'index'

  def index
    @meals = @current_user.meals.for_day(current_date)
  end

  def show
    @meal = @current_user.meals.find(params[:id].to_i)
    redirect_to(new_meal_food_item_url(@meal)) and return if @meal.food_items.size == 0
  rescue
    flash[:error] = 'Unable to display the selected meal.'
    redirect_to(meals_url)
  end

  def new
    @meal = Meal.new
  end

  def create
    @meal = @current_user.meals.build(params[:meal].merge(:created_on => current_date))
    @meal.save!
    redirect_to(meal_url(@meal))
  rescue
    flash[:error] = @meal.errors
    render(:action => 'new')
  end

  def destroy
    @meal = @current_user.meals.find(params[:id].to_i)
    @meal.destroy
  rescue
    flash[:error] = 'Unable to delete the selected meal.'
  ensure
    redirect_to(meals_url)
  end

  def edit
    @meal = @current_user.meals.find(params[:id].to_i)
  rescue
    flash[:error] = 'Unable to edit the selected meal.'
    redirect_to(meals_url)
  end

  protected

  def set_menu_item
    @activemenuitem = 'menu-meals'
  end

  def include_meal_files
    include_extra_stylesheet(:meals)
    include_extra_javascript(:meals)
  end
end
