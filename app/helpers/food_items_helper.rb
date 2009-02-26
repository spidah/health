module FoodItemsHelper
  def sort_link(title, action)
    direction = params[:dir] == 'down' ? nil : 'down' if action == params[:sort]
    link_to(title, new_meal_food_item_url(:sort => action, :dir => direction), :class => 'sort-header')
  end
  
  def get_food_item_quantities(meal_foods)
    hash = Hash.new(0)
    meal_foods.each { |food| hash[food.food_id] = food.quantity }
    hash
  end

  def food_quantity(meal_foods, food)
    @food_item_quantities ||= get_food_item_quantities(meal_foods)
    @food_item_quantities[food.id]
  end

  def food_item_form_options(meal, food)
    item = meal.food_items.detect { |fi| fi.food_id == food.id }
    if item
      return meal_food_item_url(meal, item), :put
    else
      return meal_food_items_url(meal), :post
    end
  end
end
