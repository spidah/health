class MealsController < ApplicationController
  before_filter :login_required, :set_menu_item, :include_meal_files
  before_filter :get_meal, :only => [:show, :edit, :destroy]
  before_filter :check_cancel, :only => [:create, :destroy]

  verify :method => :get, :only => [:index, :new, :edit, :show], :redirect_to => 'index'
  verify :method => :post, :only => [:create], :redirect_to => 'index'
  verify :method => [:get, :delete], :only => :destroy, :redirect_to => 'index'

  def index
    @meals = @current_user.meals.for_day(current_date)
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

  def show
    redirect_to(new_meal_food_item_url(@meal)) if @meal.food_items.size == 0
  end

  def edit
  end

  def destroy
    if request.delete?
      begin
        @meal.destroy
      rescue
        flash[:error] = 'Unable to delete the selected meal.'
      ensure
        redirect_to(meals_url)
      end
    end
  end

  protected

  def set_menu_item
    @activemenuitem = 'menu-meals'
  end

  def include_meal_files
    include_extra_stylesheet(:meals)
    include_extra_javascript(:meals)
  end

  def get_meal
    @meal = @current_user.meals.find(params[:id].to_i)
  rescue
    flash[:error] = 'Unable to find the selected meal.'
    redirect_to(meals_url)
  end

  def check_cancel
    redirect_to(meals_url) if params[:cancel]
  end
end
