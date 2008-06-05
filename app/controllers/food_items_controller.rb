class FoodItemsController < ApplicationController
  before_filter :login_required, :set_menu_item

  def new
    @meal = @current_user.meals.find(params[:meal_id])
    get_all_foods
  rescue
    redirect_to meals_path
  end

  def create
    if !@meal = get_meal(params[:meal_id])
      fail_to_meals_path('Unable to add a food item to an invalid meal.') and return
    end

    if !@food = get_food(params[:food_id])
      fail_to_meal_path(@meal, 'Unable to add the selected food item.') and return
    end

    begin
      @food_item = @meal.food_items.find_by_food_id(@food.id)
      @food_item.quantity += 1
      @food_item.save
    rescue
      @food_item = FoodItem.new
      @food_item.food_id = @food.id
      @food_item.name = @food.name
      @food_item.description = @food.description
      @food_item.calories = @food.calories
      @food_item.quantity = 1

      @meal.food_items << @food_item
    end

    redirect_to meal_path(@meal)
  end

  def edit
    if !@meal = get_meal(params[:meal_id])
      fail_to_meals_path('Unable to edit a food item for an invalid meal.') and return
    end

    if !@food_item = get_food_item(@meal, params[:id])
      fail_to_meal_path(@meal, 'Unable to edit the selected food item.') and return
    end
  end

  def update
    if !@meal = get_meal(params[:meal_id])
      fail_to_meals_path('Unable to edit a food item for an invalid meal.') and return
    end

    if !@food_item = get_food_item(@meal, params[:id])
      fail_to_meal_path(@meal, 'Unable to edit the selected food item.') and return
    end

    @food_item.quantity = params[:food_item][:quantity]
    if !@food_item.save
      flash[:error] = @food_item.errors
      redirect_to edit_meal_food_item_path(@meal, @food_item)
      return
    end

    redirect_to meal_path(@meal)
  end

  def destroy
    if !@meal = get_meal(params[:meal_id])
      fail_to_meals_path('Unable to delete a food item for an invalid meal.') and return
    end

    if !@food_item = get_food_item(@meal, params[:id])
      fail_to_meal_path(@meal, 'Unable to delete the selected food item.') and return
    end

    @food_item.destroy
    redirect_to meal_path(@meal)
  end

  protected
    def set_menu_item
      @activemenuitem = 'menu-meals'
      @overridden_controller = 'meals'
    end

    def get_all_foods
      @foods = @current_user.foods.pagination(params[:page], params[:sort], params[:dir] ? 'DESC' : 'ASC')
    end

    def get_meal(meal_id)
      @current_user.meals.find(meal_id) rescue nil
    end

    def get_food(food_id)
      @current_user.foods.find(food_id) rescue nil
    end

    def get_food_item(meal, food_id)
      meal.food_items.find(food_id) rescue nil
    end

    def fail_to_meals_path(message)
      flash[:error] = message
      redirect_to meals_path
    end

    def fail_to_meal_path(meal, message)
      flash[:error] = message
      redirect_to meal_path(meal)
    end
end
