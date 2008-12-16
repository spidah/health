require File.dirname(__FILE__) + '/../test_helper'

class FoodItemTest < Test::Unit::TestCase
  def setup
    @user = User.find(users(:spidah).id)
    @food = @user.foods.create(:name => 'Food', :description => 'Food', :manufacturer => 'Shop', :fat => 1, :protein => 1, :carbs => 1, :calories => 1)
    @meal = @user.meals.create(:name => 'Lunch')
    @valid_attributes = { :name => @food.name, :description => @food.description, :calories => @food.calories, :quantity => 1, :food_id => @food.id }
  end

  def print_errors(food_item)
    food_item.errors.full_messages.to_sentence
  end

  def test_should_create
    assert_difference(FoodItem, :count) do
      food_item = @meal.food_items.create(@valid_attributes)

      assert(!food_item.new_record?, print_errors(food_item))
    end
  end

  def test_should_require_valid_quantity
    assert_no_difference(FoodItem, :count) do
      food_item = @meal.food_items.create(@valid_attributes.merge(:quantity => 0))
      assert(food_item.new_record?)
      assert(food_item.errors.on(:quantity))
    end
  end

  def test_should_update
    food_item = @meal.food_items.create(@valid_attributes)
    assert_equal(1, food_item.quantity)

    food_item.quantity = 2
    food_item.save
    food_item.reload

    assert_equal(2, food_item.quantity)
  end

  def test_should_destroy
    food_item = @meal.food_items.create(@valid_attributes)
    food_item.destroy
    assert_raise(ActiveRecord::RecordNotFound) { FoodItem.find(food_item.id) }
  end
end
