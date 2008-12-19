require "#{File.dirname(__FILE__)}/../test_helper"

class IntegrationFoodsTest < ActionController::IntegrationTest
  def test_foods
    spidah = new_session_as(:spidah)
    spidah.login(spidah.user, spidah.openid_url)
    spidah.assert_foods_count(0)
    spidah.cant_add_invalid_food
    spidah.assert_foods_count(0)
    spidah_food = spidah.should_add_food('Sliced Ham', 'Single slice cooked ham', 'Tesco', '1g', '1', '1', '1', '15')
    spidah.should_add_food('Medium Bread', 'Single slice medium white bread', 'Kingsmill', '3g', '4.5', '9.2', '1.3', '98')
    spidah.check_food_listing(spidah_food)
    spidah.assert_foods_count(2)
    chocolate = spidah.should_add_food('Chocolate Bar', 'Plain Chocolate', 'Tesco', '3g', '3.5', '6.2', '18.2', '24')
    spidah.assert_foods_count(3)
    spidah.cant_delete_invalid_food(100000)
    spidah.should_delete_food(chocolate)
    spidah.assert_foods_count(2)
    chocolate = spidah.should_add_food('Chocolate Bar', 'Plain Chocolate', 'Tesco', '3g', '3.5', '6.2', '18.2', '24')
    spidah.should_update_food(chocolate, 'Chocolate Bar', 'Milk Chocolate', 'Nestle', '2g', '6.2', '2.1', '8.9', '12')
    chocolate = Food.find(chocolate.id)
    spidah.check_food_listing(chocolate)
    spidah.cant_update_invalid_food(1000)
    spidah.cant_update_incorrect_food(chocolate)
    spidah.check_sort_action('calories')

    bob = new_session_as(:bob)
    bob.login(bob.user, bob.openid_url)
    bob.assert_foods_count(0)
    bob.cant_delete_another_users_food(spidah_food)
  end

  module FoodTestDSL
    attr_accessor :user, :openid_url

    def assert_foods_count(count)
      assert_equal count, user.foods.count
    end

    def assert_food_form(food)
      assert_select 'div[id=food_form] form', 1
      assert_select 'legend', 'Food Details'
      assert_select 'input[type=text][value=?]', food.name
      assert_select 'input[type=text][value=?]', food.description
      assert_select 'input[type=text][value=?]', food.manufacturer
      assert_select 'input[type=text][value=?]', food.weight
      assert_select 'input[type=text][value=?]', food.fat
      assert_select 'input[type=text][value=?]', food.protein
      assert_select 'input[type=text][value=?]', food.carbs
      assert_select 'input[type=text][value=?]', food.calories
    end

    def check_food_listing(food)
      get foods_path
      assert_success('foods/index')

      assert_select "table[class=foods-list] tr td" do
        assert_select 'td[class=name]', food.name
        assert_select 'td[class=description]', food.description
        assert_select 'td[class=manufacturer]', food.manufacturer
        assert_select 'td[class=weight]', food.weight
        assert_select 'td[class=calories]', "#{food.calories}"
      end
    end

    def check_sort_action(action)
      get foods_path
      assert_success('foods/index')
      assert_select 'th a[href=?]', CGI.escapeHTML(foods_path(:sort => action))

      get foods_path(:sort => action)
      assert_success('foods/index')
      assert_select 'th a[href=?]', CGI.escapeHTML(foods_path(:sort => action, :dir => 'down'))
    end

    def cant_add_invalid_food
      post foods_path, :food => {:name => '', :description => '', :manufacturer => '', :weight => '', :fat => '', :protein => '',
        :carbs => '', :calories => ''}
      assert_success('foods/new')
      assert_flash('error', 'Please enter a name for the food.')
    end

    def should_add_food(name, description, manufacturer, weight, fat, protein, carbs, calories)
      get foods_path
      assert_success('foods/index')

      post foods_path, :food => {:name => name, :description => description, :manufacturer => manufacturer, :weight => weight,
        :fat => fat, :protein => protein, :carbs => carbs, :calories => calories}
      assert_and_follow_redirect(foods_path, 'foods/index')

      assert_no_flash('error')
      return user.foods.find(:first, :order => 'id DESC')
    end

    def should_update_food(food, name, description, manufacturer, weight, fat, protein, carbs, calories)
      get edit_food_path(food)
      assert_success('foods/edit')
      assert_food_form(food)

      put food_path(food), :food => {:name => name, :description => description, :manufacturer => manufacturer, :weight => weight,
        :fat => fat, :protein => protein, :carbs => carbs, :calories => calories}
      assert_and_follow_redirect(foods_path, 'foods/index')

      assert_no_flash('error')
    end

    def cant_update_invalid_food(id)
      get edit_food_path(id)
      assert_and_follow_redirect(foods_path, 'foods/index')
      assert_flash('error', 'Unable to edit the selected food.')

      put food_path(id), :food => {:name => 'foo'}
      assert_and_follow_redirect(foods_path, 'foods/index')
      assert_flash('error', 'Unable to update the selected food.')
    end

    def cant_update_incorrect_food(food)
      put food_path(food), :food => {:name => ''}
      assert_and_follow_redirect(foods_path, 'foods/index')
      assert_flash('error', 'Please enter a name for the food.')
    end

    def should_delete_food(food)
      delete food_path(food)
      assert_and_follow_redirect(foods_path, 'foods/index')
      assert_no_flash('error')
    end

    def cant_delete_invalid_food(id)
      delete food_path(id)
      assert_and_follow_redirect(foods_path, 'foods/index')
      assert_flash('error', 'Unable to delete the selected food.')
    end

    def cant_delete_another_users_food(food)
      delete food_path(food)
      assert_and_follow_redirect(foods_path, 'foods/index')
      assert_flash('error', 'Unable to delete the selected food.')
    end
  end

  def new_session_as(user)
    open_session do |session|
      session.extend(FoodTestDSL)
      session.user = get_user(users(user))
      session.openid_url = user_logins(user).openid_url
      yield session if block_given?
    end
  end
end
