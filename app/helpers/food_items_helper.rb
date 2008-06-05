module FoodItemsHelper
  def sort_link(title, action)
    direction = nil
    if action == params[:sort]
      direction = params[:dir] == 'down' ? nil : 'down'        
    end
    link_to(title, new_meal_food_item_path(:meal => @meal, :sort => action, :dir => direction), :class => 'sort-header')
  end
end
