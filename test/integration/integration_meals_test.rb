require "#{File.dirname(__FILE__)}/../test_helper"

class IntegrationMealsTest < ActionController::IntegrationTest
  def test_meals
    spidah = new_session_as(:spidah)
    spidah.login(spidah.user, spidah.openid_url)
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
    spidah.add_food_multiple_times(lunch, bread, 1, 3, 4)
    spidah.add_food_multiple_times(lunch, ham, 1, 3, 4)
    spidah.check_food_quantity(lunch, bread, 4)
    spidah.check_food_quantity(lunch, ham, 4)
    spidah.check_total_calories(lunch, (4 * bread.calories) + (4 * ham.calories))
    spidah.should_remove_food_item(lunch, ham_fi)
    spidah.check_total_calories(lunch, 4 * bread.calories)
    
    ham_fi = spidah.should_add_food_to_meal(lunch, ham)
    spidah.inc_food_item_quantity(lunch, ham_fi)
    spidah.check_food_quantity(lunch, ham, 2)
    spidah.dec_food_item_quantity(lunch, ham_fi)
    spidah.check_food_quantity(lunch, ham, 1)

    spidah.should_destroy_food_item_with_dec(lunch, ham_fi, ham)

    spidah.cant_add_with_invalid_food_or_meal(lunch, bread)
    spidah.cant_delete_with_invalid_fooditem_or_meal(lunch, bread_fi)
    spidah.cant_show_invalid_meal(1000)

    bob = new_session_as(:bob)
    bob.login(bob.user, bob.openid_url)
    bob.cant_show_another_users_meal(lunch)
    bob.cant_update_another_users_meal(lunch)
    bob.cant_delete_another_users_meal(lunch)

    dinner = spidah.should_add_meal('Dinner')
    ham = spidah.add_food('Sliced Ham', 'Single slice cooked ham', 'Tesco', '1g', '1', '1', '1', '15')
    ham_fi = spidah.should_add_food_to_meal(dinner, ham)
    spidah.should_update_food_item_when_food_updated(dinner, ham, ham_fi)
    spidah.should_delete_meal(dinner)

    spidah.check_meal_count(1)
    spidah.change_date(Date.yesterday)
    spidah.check_meal_count(0)
    spidah.should_add_meal('Lunch')
    spidah.check_meal_count(1)
    spidah.change_date(Date.today)

    spidah.check_meal_count(1)
    spidah.should_delete_meal(lunch)
    spidah.check_meal_count(0)
    spidah.check_cant_find_food_item(bread_fi)
  end

  module MealTestDSL
    attr_accessor :user, :openid_url

    def get_latest_meal
      user.meals.find(:first, :order => 'id DESC')
    end

    def assert_new_food_item_quantity(food, quantity)
      assert_select('tr[class=food-item]') do
        assert_select('td[class=name]', food.name)
        assert_select('td[class=add] form span[class=quantity]', "#{quantity}")
      end
    end

    def check_meal_count(count)
      get(meals_url)
      assert_success('meals/index')
      assert_select('fieldset', count)
    end

    def check_food_listings(meal, foods)
      get(new_meal_food_item_url(meal))
      assert_success('food_items/new')

      foods.each { |food|
        assert_select('td[class=name]', food.name)
        assert_select('td[class=description]', food.description)
        assert_select('td[class=manufacturer]', food.manufacturer)
        assert_select('td[class=weight]', food.weight)
      }
    end

    def check_food_item(meal, food_item)
      get(meal_url(meal))
      assert_success('meals/show')

      assert_select('table tr td') do
        assert_select('td[class=name]', food_item.name)
        assert_select('td[class*=quantity]', food_item.quantity.to_s)
        assert_select('td[class*=calories]', food_item.calories.to_s)
      end
    end

    def check_food_quantity(meal, food, quantity)
      get(meal_url(meal))
      assert_select('td[class=name]', food.name)
      assert_select('td[class*=quantity]', "#{quantity}")
    end

    def check_total_calories(meal, calories)
      get(meal_url(meal))
      assert_select('td[class*=total-calories]', "#{calories}")
    end

    def check_sort_action(meal, action)
      get(new_meal_food_item_url(meal))
      assert_success('food_items/new')
      assert_select('th a[href=?]', CGI.escapeHTML(new_meal_food_item_url(meal, :sort => action)))

      get(new_meal_food_item_url(meal, :sort => action))
      assert_success('food_items/new')
      assert_select('th a[href=?]', CGI.escapeHTML(new_meal_food_item_url(meal, :sort => action, :dir => 'down')))
    end

    def check_cant_find_food_item(food_item)
      assert(!FoodItem.exists?(food_item.id))
    end

    def add_food(name, description, manufacturer, weight, fat, protein, carbs, calories)
      post(foods_url, :food => {:name => name, :description => description, :manufacturer => manufacturer, :weight => weight,
        :fat => fat, :protein => protein, :carbs => carbs, :calories => calories})
      return user.foods.find(:first, :order => 'id DESC')
    end

    def should_add_meal(name)
      get(new_meal_url)
      assert_success('meals/new')

      post(meals_url, :meal => {:name => name})
      meal = get_latest_meal
      assert_redirected_to(meal_url(meal))
      follow_redirect!
      assert_redirected_to(new_meal_food_item_url(meal))
      follow_redirect!
      assert_template('food_items/new')
      assert_no_flash('error')
      return meal
    end

    def cant_add_invalid_meal
      post(meals_url, :meal => {:name => ''})
      assert_success('meals/new')
      assert_flash('error', nil, 'Error saving meal')
      assert_flash_item('error', 'Please enter a meal name.')
    end

    def should_add_food_to_meal(meal, food)
      post(meal_food_items_url(meal), :food_id => food.id, :action_type => 'new', :submit => 'add')
      assert_and_follow_redirect(new_meal_food_item_url(meal), 'food_items/new')
      
      assert_new_food_item_quantity(food, 1)

      get(meal_url(meal))
      assert_success('meals/show')
      
      assert_select('tr') do
        assert_select('td[class=name]', food.name)
        assert_select('td[class*=quantity]', "1")
        assert_select('td[class*=calories]', "#{food.calories}")
      end

      meal.reload
      return meal.food_items.find(:first, :conditions => {:food_id => food.id})
    end

    def add_food_multiple_times(meal, food, existing_quantity, to_add, new_quantity)
      get(new_meal_food_item_url(meal))
      assert_new_food_item_quantity(food, existing_quantity)

      to_add.times do
        post(meal_food_items_url(meal), :food_id => food.id, :action_type => 'new', :submit => 'add')
      end
      
      get(new_meal_food_item_url(meal))
      assert_new_food_item_quantity(food, new_quantity)
    end

    def inc_food_item_quantity(meal, food_item)
      put(meal_food_item_url(meal, food_item), :submit => 'add')
    end

    def dec_food_item_quantity(meal, food_item)
      put(meal_food_item_url(meal, food_item), :submit => 'delete')
    end

    def should_destroy_food_item_with_dec(meal, food_item, food)
      dec_food_item_quantity(meal, food_item)
      
      get(new_meal_food_item_url(meal))
      assert_new_food_item_quantity(food, 0)
      assert_raise(ActiveRecord::RecordNotFound) { meal.food_items.find(food_item) }
    end

    def should_update_food_item_when_food_updated(meal, food, food_item)
      put(food_url(food), :food => {:name => 'Food', :description => 'Food', :calories => 1})
      food_item = FoodItem.find(food_item.id)
      check_food_item(meal, food_item)
    end

    def should_remove_food_item(meal, food_item)
      delete(meal_food_item_url(meal, food_item))
      assert_and_follow_redirect(meal_url(meal), 'meals/show')
      assert_no_flash('error')
    end

    def should_delete_meal(meal)
      delete(meal_url(meal))
      assert_and_follow_redirect(meals_url, 'meals/index')
    end

    def cant_add_with_invalid_food_or_meal(meal, food)
      get(new_meal_food_item_url(1000))
      assert_redirected_to meals_url

      post(meal_food_items_url(100), :food_id => food)
      assert_and_follow_redirect(meals_url, 'meals/index')
      assert_flash('error', 'Unable to add a food item to an invalid meal.')

      post(meal_food_items_url(meal), :food_id => 1000)
      assert_and_follow_redirect(meal_url(meal), 'meals/show')
      assert_flash('error', 'Unable to add the selected food item.')
    end

    def cant_delete_with_invalid_fooditem_or_meal(meal, food_item)
      delete(meal_food_item_url(1000, food_item))
      assert_and_follow_redirect(meals_url, 'meals/index')
      assert_flash('error', 'Unable to delete a food item for an invalid meal.')

      delete(meal_food_item_url(meal, 1000))
      assert_and_follow_redirect(meal_url(meal), 'meals/show')
      assert_flash('error', 'Unable to delete the selected food item.')
    end

    def cant_show_invalid_meal(id)
      get(meal_url(id))
      assert_and_follow_redirect(meals_url, 'meals/index')
      assert_flash('error', 'Unable to display the selected meal.')
    end

    def cant_show_another_users_meal(meal)
      get(meal_url(meal))
      assert_and_follow_redirect(meals_url, 'meals/index')
      assert_flash('error', 'Unable to display the selected meal.')
    end

    def cant_update_another_users_meal(meal)
      get(edit_meal_url(meal))
      assert_and_follow_redirect(meals_url, 'meals/index')
      assert_flash('error', 'Unable to edit the selected meal.')
    end

    def cant_delete_another_users_meal(meal)
      delete(meal_url(meal))
      assert_and_follow_redirect(meals_url, 'meals/index')
      assert_flash('error', 'Unable to delete the selected meal.')
    end
  end

  def new_session_as(user)
    open_session do |session|
      session.extend(MealTestDSL)
      session.user = get_user(users(user))
      session.openid_url = user_logins(user).openid_url
      yield session if block_given?
    end
  end
end
