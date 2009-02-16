class FoodItemsController < ApplicationController
  before_filter :login_required, :set_menu_item

  verify :method => :get, :only => [:new, :edit], :redirect_to => 'index'
  verify :method => :post, :only => :create, :redirect_to => 'index'
  verify :method => :put, :only => :update, :redirect_to => 'index'
  verify :method => :delete, :only => :destroy, :redirect_to => 'index'

  def new
    include_extra_stylesheet(:foods)
    @meal = @current_user.meals.find(params[:meal_id].to_i)
    get_all_foods
  rescue
    redirect_to(meals_path)
  end

  def create
    @meal = get_meal('Unable to add a food item to an invalid meal.') || return
    @food = get_food('Unable to add the selected food item.') || return
    
    if params['add.x'] || params[:submit] == 'add'
      begin
        @meal.food_items.find_by_food_id(@food.id).increment!(:quantity)
      rescue
        @meal.food_items.create({:food_id => @food.id, :name => @food.name,
          :description => @food.description, :calories => @food.calories, :quantity => 1})
      end
    end

    redirect_to(new_meal_food_item_path(@meal))
  end

  def edit
    @meal = get_meal('Unable to edit a food item for an invalid meal.') || return
    @food_item = get_food_item('Unable to edit the selected food item.') || return
  end

  def update
    @meal = get_meal('Unable to edit a food item for an invalid meal.') || return
    @food_item = get_food_item('Unable to edit the selected food item.') || return
    
    if params['add.x'] || params['delete.x'] || params[:submit]
      handle_quantity_change
    else
      @food_item.quantity = params[:food_item][:quantity]
      if !@food_item.save
        flash[:error] = @food_item.errors
        redirect_to(edit_meal_food_item_path(@meal, @food_item))
        return
      end
      if params[:action_type] == 'new'
        redirect_to(new_meal_food_item_url(@meal))
      else
        redirect_to(meal_path(@meal))
      end
    end
  end

  def destroy
    @meal = get_meal('Unable to delete a food item for an invalid meal.') || return
    @food_item = get_food_item('Unable to delete the selected food item.') || return
    
    @food_item.destroy
    redirect_to(meal_path(@meal))
  end

  protected
    def set_menu_item
      @activemenuitem = 'menu-meals'
      @overridden_controller = 'meals'
    end

    def get_all_foods
      @foods = @current_user.foods.pagination(params[:page], params[:sort] || 'name', params[:dir] ? 'DESC' : 'ASC')
    end

    def get_meal(error_message)
      @current_user.meals.find(params[:meal_id].to_i, :include => :food_items)
    rescue
      fail_to_meals_path(error_message)
      nil
    end

    def get_food(error_message)
      @current_user.foods.find(params[:food_id].to_i)
    rescue
      fail_to_meal_path(@meal, error_message)
      nil
    end

    def get_food_item(error_message)
      @meal.food_items.find(params[:id].to_i)
    rescue
      fail_to_meal_path(@meal, error_message)
      nil
    end

    def fail_to_meals_path(message)
      flash[:error] = message
      redirect_to(meals_path)
    end

    def fail_to_meal_path(meal, message)
      flash[:error] = message
      redirect_to(meal_path(meal))
    end

    def handle_quantity_change
      params[:submit] = 'add' if params['add.x']
      params[:submit] = 'delete' if params['delete.x']
      params[:action_type] = 'update' if !params[:action_type]
      
      if params[:submit] == 'add'
        @food_item.increment!(:quantity)
      elsif params[:submit] == 'delete'
        @food_item.decrement!(:quantity)
        if @food_item.quantity < 1
          @food_item.destroy
          render(:nothing => true)
        end
      end

      request.xhr? ? render(:partial => 'meals/food_item', :object => @food_item) :
        redirect_to(params[:action_type] == 'new' ? new_meal_food_item_url(@meal) : meal_url(@meal))
    end
end
