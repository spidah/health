class FoodItemsController < ApplicationController
  before_filter :login_required, :set_menu_item
  before_filter :get_meal
  before_filter :get_food, :only => :create
  before_filter :get_food_item, :only => [:edit, :update, :destroy]
  before_filter :check_cancel, :only => [:destroy]

  verify :method => :get, :only => [:new, :edit], :redirect_to => 'index'
  verify :method => :post, :only => :create, :redirect_to => 'index'
  verify :method => :put, :only => :update, :redirect_to => 'index'
  verify :method => [:get, :delete], :only => :destroy, :redirect_to => 'index'

  def new
    include_extra_stylesheet(:foods)
    include_extra_javascript(:foods)
    @meal = @current_user.meals.find(params[:meal_id].to_i)
    get_all_foods
  rescue
    redirect_to(meals_url)
  end

  def create
    if params['add.x'] || params[:submit] == 'add'
      begin
        @meal.food_items.find_by_food_id(@food.id).increment!(:quantity)
      rescue
        @meal.food_items.create({:food_id => @food.id, :name => @food.name,
          :description => @food.description, :calories => @food.calories, :quantity => 1})
      end
    end

    if request.xhr?
      @meal.food_items(true)
      render(:partial => 'food_items/food', :object => @current_user.foods.find(params[:food_id].to_i))
    else
      redirect_to(new_meal_food_item_url(@meal))
    end
  end

  def edit
  end

  def update
    if params['add.x'] || params['remove.x'] || params[:submit]
      handle_quantity_change
    else
      @food_item.quantity = params[:food_item][:quantity]
      if !@food_item.save
        flash[:error] = @food_item.errors
        redirect_to(edit_meal_food_item_url(@meal, @food_item))
        return
      end
      if params[:action_type] == 'new'
        redirect_to(new_meal_food_item_url(@meal))
      else
        redirect_to(meal_url(@meal))
      end
    end
  end

  def destroy
    if request.delete?
      @food_item.destroy
      redirect_to(meal_url(@meal))
    end
  end

  protected

  def set_menu_item
    @activemenuitem = 'menu-meals'
    @overridden_controller = 'meals'
  end

  def get_all_foods
    @foods = @current_user.foods.pagination(params[:page], params[:sort] || 'name', params[:dir] ? 'DESC' : 'ASC')
  end

  def get_meal
    @meal = @current_user.meals.find(params[:meal_id].to_i, :include => :food_items)
  rescue
    fail_to_meals_url('Unable to find the selected meal.')
  end

  def get_food
    @food = @current_user.foods.find(params[:food_id].to_i)
  rescue
    fail_to_meal_url(@meal, 'Unable to find the selected food.')
  end

  def get_food_item
    @food_item = @meal.food_items.find(params[:id].to_i)
  rescue
    fail_to_meal_url(@meal, 'Unable to find the selected food item.')
  end

  def fail_to_meals_url(message)
    flash[:error] = message
    redirect_to(meals_url)
  end

  def fail_to_meal_url(meal, message)
    flash[:error] = message
    redirect_to(meal_url(meal))
  end

  def handle_quantity_change
    params[:submit] = 'add' if params['add.x']
    params[:submit] = 'remove' if params['remove.x']
    params[:action_type] = 'update' if !params[:action_type]

    if params[:submit] == 'add'
      @food_item.increment!(:quantity)
    elsif params[:submit] == 'remove'
      @food_item.decrement!(:quantity)
      if @food_item.quantity < 1
        @food_item.destroy
      end
    end

    @meal.food_items(true)

    if params[:action_type] == 'new'
      # sender: new meal food item page 'meals/x/food_items/new'
      if request.xhr?
        render(:partial => 'food_items/food', :object => @current_user.foods.find(@food_item.food_id))
      else
        redirect_to(new_meal_food_item_url(@meal))
      end
    else
      # sender: meal page 'meals/x'
      if request.xhr?
        render(:partial => 'meals/food_item', :object => @food_item)
      else
        redirect_to(meal_url(@meal))
      end
    end
  end

  def check_cancel
    redirect_to(meal_url(@meal)) if params[:cancel]
  end
end
