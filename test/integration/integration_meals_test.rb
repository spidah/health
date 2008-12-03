require "#{File.dirname(__FILE__)}/../test_helper"

class IntegrationMealsTest < ActionController::IntegrationTest
  def test_meals
    spidah = new_session_as(get_user(users(:spidah)))
    spidah.login(user_logins(:spidah).openid_url)
    bread = spidah.add_food('Medium Bread', 'Single slice medium white bread', 'Kingsmill', '3g', '4.5', '9.2', '1.3', '98')
    ham = spidah.add_food('Sliced Ham', 'Single slice cooked ham', 'Tesco', '1g', '1', '1', '1', '15')

    spidah.check_meal_count(0)
    lunch = spidah.should_add_meal('Lunch')
    spidah.check_meal_count(1)
    spidah.cant_add_invalid_meal
    spidah.check_meal_count(1)

    spidah.check_sort_action(lunch, 'name')

    spidah.check_food_listings(lunch, [bread, ham])

    bread_fi = spidah.should_add_food_to_meal(lunch, bread)
    ham_fi = spidah.should_add_food_to_meal(lunch, ham)
    spidah.should_add_food_to_meal(lunch, bread, 2)
    spidah.should_update_food_item_quantity(lunch, bread_fi, 2, 4)
    spidah.should_update_food_item_quantity(lunch, ham_fi, 1, 4)
    spidah.check_food_quantity(lunch, bread, 4)
    spidah.check_food_quantity(lunch, ham, 4)
    spidah.check_total_calories(lunch, (4 * 98) + (4 * 15))
    spidah.should_remove_food_item(lunch, ham_fi)
    spidah.check_total_calories(lunch, 4 * 98)

    spidah.cant_add_with_invalid_food_or_meal(lunch, bread)
    spidah.cant_edit_with_invalid_fooditem_or_meal(lunch, bread_fi)
    spidah.cant_update_with_invalid_fooditem_meal_or_quantity(lunch, bread_fi, 1)
    spidah.cant_delete_with_invalid_fooditem_or_meal(lunch, bread_fi)
    spidah.cant_show_invalid_meal(1000)

    bob = new_session_as(get_user(users(:bob)))
    bob.login(user_logins(:bob).openid_url)
    bob.cant_show_another_users_meal(lunch)
    bob.cant_update_another_users_meal(lunch)
    bob.cant_delete_another_users_meal(lunch)
    
    spidah.check_meal_count(1)
    spidah.should_delete_meal(lunch)
    spidah.check_meal_count(0)
    spidah.check_cant_find_food_item(bread_fi)
  end

  module MealTestDSL
    attr_accessor :user

    def login(openid_url)
      $mockuser = user
      post session_path, :openid_url => openid_url
      get open_id_complete_path, :openid_url => openid_url, :open_id_complete => 1
      assert_dashboard_redirect
    end

    def get_latest_meal
      user.meals.find(:first, :order => 'id DESC')
    end

    def check_meal_count(count)
      user.meals.reload
      assert_equal count, user.meals.size
    end

    def check_food_listings(meal, foods)
      get new_meal_food_item_path(meal)
      assert_success('food_items/new')

      foods.each { |food|
        assert_select 'td[class=name]', food.name
        assert_select 'td[class=description]', food.description
        assert_select 'td[class=manufacturer]', food.manufacturer
        assert_select 'td[class=weight]', food.weight
      }
    end

    def check_food_quantity(meal, food, quantity)
      get meal_path(meal)
      assert_select 'td[class=name]', food.name
      assert_select "td[class='quantity number']", "#{quantity}"
    end

    def check_total_calories(meal, calories)
      get meal_path(meal)
      assert_select "td[class='total-calories number']", "#{calories}"
    end

    def check_sort_action(meal, action)
      get new_meal_food_item_path(meal)
      assert_success('food_items/new')
      assert_select 'th a[href=?]', CGI.escapeHTML(new_meal_food_item_path(meal, :sort => action))

      get new_meal_food_item_path(meal, :sort => action)
      assert_success('food_items/new')
      assert_select 'th a[href=?]', CGI.escapeHTML(new_meal_food_item_path(meal, :sort => action, :dir => 'down'))
    end

    def check_cant_find_food_item(food_item)
      assert_equal false, FoodItem.exists?(food_item.id)
    end

    def add_food(name, description, manufacturer, weight, fat, protein, carbs, calories)
      post foods_path, :food => {:name => name, :description => description, :manufacturer => manufacturer, :weight => weight,
        :fat => fat, :protein => protein, :carbs => carbs, :calories => calories}
      return user.foods.find(:first, :order => 'id DESC')
    end

    def should_add_meal(name)
      get new_meal_path
      assert_success('meals/new')

      post meals_path, :meal => {:name => name}
      meal = get_latest_meal
      assert_redirected_to(meal_path(meal))
      follow_redirect!
      assert_redirected_to(new_meal_food_item_path(meal))
      follow_redirect!
      assert_template('food_items/new')
      assert_no_flash('error')
      return meal
    end

    def cant_add_invalid_meal
      post meals_path, :meal => {:name => ''}
      assert_success('meals/new')
      assert_flash('error', nil, 'Error saving meal')
      assert_flash_item('error', 'Please enter a meal name.')
    end

    def should_add_food_to_meal(meal, food, quantity = 1)
      post meal_food_items_path(meal), :food_id => food.id
      assert_and_follow_redirect(meal_path(meal), 'meals/show')

      assert_select 'td[class=name]', food.name
      assert_select "td[class='quantity number']", "#{quantity}"
      assert_select "td[class='calories number']", "#{quantity * food.calories}"

      meal.reload
      return meal.food_items.find(:first, :conditions => {:food_id => food.id})
    end

    def should_update_food_item_quantity(meal, food_item, existing_quantity, new_quantity)
      get edit_meal_food_item_path(meal, food_item)
      assert_select 'option[selected=selected]', "#{existing_quantity}"

      put meal_food_item_path(meal, food_item), :food_item => {:quantity => new_quantity}
      assert_and_follow_redirect(meal_path(meal), 'meals/show')
    end

    def should_remove_food_item(meal, food_item)
      delete meal_food_item_path(meal, food_item)
      assert_and_follow_redirect(meal_path(meal), 'meals/show')
      assert_no_flash('error')
    end

    def should_delete_meal(meal)
      delete meal_path(meal)
      assert_and_follow_redirect(meals_path, 'meals/index')
    end

    def cant_add_with_invalid_food_or_meal(meal, food)
      get new_meal_food_item_path(1000)
      assert_redirected_to meals_path

      post meal_food_items_path(100), :food_id => food
      assert_and_follow_redirect(meals_path, 'meals/index')
      assert_flash('error', 'Unable to add a food item to an invalid meal.')

      post meal_food_items_path(meal), :food_id => 1000
      assert_and_follow_redirect(meal_path(meal), 'meals/show')
      assert_flash('error', 'Unable to add the selected food item.')
    end

    def cant_edit_with_invalid_fooditem_or_meal(meal, fooditem)
      get edit_meal_food_item_path(1000, fooditem)
      assert_and_follow_redirect(meals_path, 'meals/index')
      assert_flash('error', 'Unable to edit a food item for an invalid meal.')

      get edit_meal_food_item_path(meal, 1000)
      assert_and_follow_redirect(meal_path(meal), 'meals/show')
      assert_flash('error', 'Unable to edit the selected food item.')
    end

    def cant_update_with_invalid_fooditem_meal_or_quantity(meal, fooditem, quantity)
      put meal_food_item_path(1000, fooditem), :food_item => {:quantity => quantity}
      assert_and_follow_redirect(meals_path, 'meals/index')
      assert_flash('error', 'Unable to edit a food item for an invalid meal.')

      put meal_food_item_path(meal, 1000), :food_item => {:quantity => quantity}
      assert_and_follow_redirect(meal_path(meal), 'meals/show')
      assert_flash('error', 'Unable to edit the selected food item.')

      put meal_food_item_path(meal, fooditem), :food_item => {:quantity => 0}
      assert_and_follow_redirect(edit_meal_food_item_path(meal, fooditem), 'food_items/edit')
      assert_flash('error', 'You need a quantity of at least 1.')
    end

    def cant_delete_with_invalid_fooditem_or_meal(meal, food_item)
      delete meal_food_item_path(1000, food_item)
      assert_and_follow_redirect(meals_path, 'meals/index')
      assert_flash('error', 'Unable to delete a food item for an invalid meal.')

      delete meal_food_item_path(meal, 1000)
      assert_and_follow_redirect(meal_path(meal), 'meals/show')
      assert_flash('error', 'Unable to delete the selected food item.')
    end

    def cant_show_invalid_meal(id)
      get meal_path(id)
      assert_and_follow_redirect(meals_path, 'meals/index')
      assert_flash('error', 'Unable to display the selected meal.')
    end
    
    def cant_show_another_users_meal(meal)
      get meal_path(meal)
      assert_and_follow_redirect(meals_path, 'meals/index')
      assert_flash('error', 'Unable to display the selected meal.')
    end

    def cant_update_another_users_meal(meal)
      get edit_meal_path(meal)
      assert_and_follow_redirect(meals_path, 'meals/index')
      assert_flash('error', 'Unable to edit the selected meal.')
    end

    def cant_delete_another_users_meal(meal)
      delete meal_path(meal)
      assert_and_follow_redirect(meals_path, 'meals/index')
      assert_flash('error', 'Unable to delete the selected meal.')
    end
  end

  def new_session_as(user)
    open_session do |session|
      session.extend(MealTestDSL)
      session.user = user
      yield session if block_given?
    end
  end
end
