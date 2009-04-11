require File.dirname(__FILE__) + '/../test_helper'

class MealTest < ActiveSupport::TestCase
  def setup
    @user = User.find(users(:spidah).id)
    @food = @user.foods.create(:name => 'Food', :description => 'Food', :manufacturer => 'Shop', :fat => 1, :protein => 1, :carbs => 1, :calories => 1)
    @valid_attributes = { :name => 'Lunch', :created_on => Date.today }
  end

  def print_errors(meal)
    meal.errors.full_messages.to_sentence
  end

  def test_should_create
    assert_difference(Meal, :count) do
      meal = @user.meals.create(@valid_attributes)

      assert(!meal.new_record?, print_errors(meal))
    end
  end

  def test_should_require_name
    assert_no_difference(Meal, :count) do
      meal = @user.meals.create(@valid_attributes.except(:name))

      assert(meal.new_record?)
      assert(meal.errors.on(:name))
    end
  end

  def test_should_update
    meal = @user.meals.create(@valid_attributes)
    assert_equal('Lunch', meal.name)

    meal.update_attributes(:name => 'Dinner')
    meal.reload

    assert_equal('Dinner', meal.name)
  end

  def test_should_update_total_calories
    meal = @user.meals.create(@valid_attributes)
    assert_equal(0, meal.total_calories)

    meal.food_items.create(:food_id => @food, :name => @food.name, :description => @food.description, :calories => @food.calories, :quantity => 1)
    meal = Meal.find(meal.id)

    assert_equal(1, meal.total_calories)
  end

  def test_should_find_for_specific_day_only
    today = @user.meals.create(@valid_attributes)
    tomorrow = @user.meals.create(@valid_attributes.merge(:created_on => Date.tomorrow))

    meals = @user.meals.for_day(Date.today)
    assert(meals.include?(today))
    assert(!meals.include?(tomorrow))
  end

  def test_should_return_calorie_sum_for_specific_day
    lunch = @user.meals.create(@valid_attributes)
    dinner = @user.meals.create(@valid_attributes.merge(:name => 'Dinner'))
    tomorrow = @user.meals.create(@valid_attributes.merge(:created_on => Date.tomorrow))

    lunch.food_items.create(:food_id => @food, :name => @food.name, :description => @food.description, :calories => @food.calories, :quantity => 2)
    dinner.food_items.create(:food_id => @food, :name => @food.name, :description => @food.description, :calories => @food.calories, :quantity => 1)
    tomorrow.food_items.create(:food_id => @food, :name => @food.name, :description => @food.description, :calories => @food.calories, :quantity => 5)

    calories = @user.meals.for_day(Date.today).calories
    assert_equal(3, calories)
  end

  def test_should_return_meal_count_for_specific_day
    lunch = @user.meals.create(@valid_attributes)
    dinner = @user.meals.create(@valid_attributes.merge(:name => 'Dinner'))
    tomorrow = @user.meals.create(@valid_attributes.merge(:created_on => Date.tomorrow))

    lunch.food_items.create(:food_id => @food, :name => @food.name, :description => @food.description, :calories => @food.calories, :quantity => 2)
    dinner.food_items.create(:food_id => @food, :name => @food.name, :description => @food.description, :calories => @food.calories, :quantity => 1)
    tomorrow.food_items.create(:food_id => @food, :name => @food.name, :description => @food.description, :calories => @food.calories, :quantity => 5)

    count = @user.meals.for_day(Date.today).get_count
    assert_equal(2, count)
  end

  def test_should_return_latest_meal
    tomorrow = @user.meals.create(@valid_attributes.merge(:created_on => Date.tomorrow))
    today = @user.meals.create(@valid_attributes)

    date = @user.meals.get_latest_date
    assert_equal(Date.tomorrow, date)
  end

  def test_should_destroy
    meal = @user.meals.create(@valid_attributes)
    meal.destroy

    assert_raise(ActiveRecord::RecordNotFound) { Meal.find(meal.id) }
  end
end
