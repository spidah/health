require File.dirname(__FILE__) + '/../test_helper'

class FoodTest < ActiveSupport::TestCase
  def setup
    @user = User.find(users(:spidah).id)
    @valid_attributes = { :name => 'Food', :description => 'Food', :manufacturer => 'Shop', :weight => '1', :fat => 1, :protein => 1, :carbs => 1, :calories => 1 }
  end

  def print_errors(food)
    food.errors.full_messages.to_sentence
  end

  def test_should_create
    assert_difference(Food, :count) do
      food = @user.foods.create(@valid_attributes)
      assert(!food.new_record?, print_errors(food))
    end
  end

  def test_should_require_name
    assert_no_difference(Food, :count) do
      food = @user.foods.create(@valid_attributes.except(:name))
      assert(food.new_record?)
      assert(food.errors.on(:name))
    end
  end

  def test_should_require_valid_attributes
    [:fat, :protein, :carbs, :calories].each { |attribute|
      assert_no_difference(Food, :count) do
        food = @user.foods.create(@valid_attributes.merge(attribute => -1))
        assert(food.new_record?)
        assert(food.errors.on(attribute))
      end
    }
  end

  def test_should_update
    food = @user.foods.create(@valid_attributes)
    assert_equal('Food', food.name)
    assert_equal('Food', food.description)
    assert_equal('Shop', food.manufacturer)
    assert_equal('1', food.weight)
    assert_equal(1, food.fat)
    assert_equal(1, food.protein)
    assert_equal(1, food.carbs)
    assert_equal(1, food.calories)

    food.update_attributes(:name => 'Not Food', :description => 'Not Food', :manufacturer => 'Not Shop', :weight => '2', :fat => 2, :protein => 2, :carbs => 2, :calories => 2)
    food.reload

    assert_equal('Not Food', food.name)
    assert_equal('Not Food', food.description)
    assert_equal('Not Shop', food.manufacturer)
    assert_equal('2', food.weight)
    assert_equal(2, food.fat)
    assert_equal(2, food.protein)
    assert_equal(2, food.carbs)
    assert_equal(2, food.calories)
  end

  def test_should_destroy
    food = @user.foods.create(@valid_attributes)
    food.destroy
    assert_raise(ActiveRecord::RecordNotFound) { Food.find(food.id) }
  end
end
