require File.dirname(__FILE__) + '/../test_helper'

class WeightTest < Test::Unit::TestCase
  def setup
    @user_lbs = User.find(users(:spidah).id)
    @user_kg = User.find(users(:jimmy).id)
  end

  def create_lbs_weight(taken_on = nil, stone = nil, lbs = nil)
    w = Weight.new(:taken_on => taken_on, :stone => stone, :lbs => lbs, :weight_units => 'lbs')
    @user_lbs.weights << w
    w
  end

  def create_kg_weight(taken_on = nil, weight = nil)
    w = Weight.new(:taken_on => taken_on, :weight => weight, :weight_units => 'kg')
    @user_kg.weights << w
    w
  end

  def test_should_create_weight
    assert_difference Weight, :count do
      w = create_lbs_weight(Date.today, 10, 10)
      assert !w.new_record?, "#{w.errors.full_messages.to_sentence}"
    end

    assert_difference Weight, :count do
      w = create_kg_weight(Date.today, 50)
      assert !w.new_record?, "#{w.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_weight
    assert_no_difference Weight, :count do
      w = create_lbs_weight(Date.today)
      assert w.errors.on(:weight)
    end

    assert_no_difference Weight, :count do
      w = create_kg_weight(Date.today)
      assert w.errors.on(:weight)
    end
  end

  def test_should_require_taken_on
    assert_no_difference Weight, :count do
      w = create_lbs_weight(nil, 10, 10)
      assert w.errors.on(:taken_on)
    end

    assert_no_difference Weight, :count do
      w = create_kg_weight(nil, 50)
      assert w.errors.on(:taken_on)
    end
  end

  def test_should_require_valid_weight
    assert_no_difference Weight, :count do
      w = create_lbs_weight(Date.today, 0, 0)
      assert w.errors.on(:weight)
    end

    assert_no_difference Weight, :count do
      w = create_lbs_weight(Date.today, 'a', 'a')
      assert w.errors.on(:weight)
    end

    assert_no_difference Weight, :count do
      w = create_lbs_weight(Date.today, -10, -10)
      assert w.errors.on(:weight)
    end

    assert_no_difference Weight, :count do
      w = create_kg_weight(Date.today, 0)
      assert w.errors.on(:weight)
    end

    assert_no_difference Weight, :count do
      w = create_kg_weight(Date.today, 'a')
      assert w.errors.on(:weight)
    end

    assert_no_difference Weight, :count do
      w = create_kg_weight(Date.today, -10)
      assert w.errors.on(:weight)
    end
  end

  def test_should_format_weight
    w = create_lbs_weight(Date.today, 10, 9)
    assert_equal '10 stone 9 lbs', w.format

    w = create_lbs_weight(Date.today, 10, 1)
    assert_equal '10 stone 1 lb', w.format

    w = create_lbs_weight(Date.today, 0, 1)
    assert_equal '1 lb', w.format

    w = create_kg_weight(Date.today, 50)
    assert_equal '50 kg', w.format
  end

  def test_should_update_difference
    w1 = create_lbs_weight(Date.today, 10, 0)
    w2 = create_lbs_weight(Date.today + 1.day, 10, 1)
    w3 = create_lbs_weight(Date.today + 2.days, 9, 2)
    assert_equal 0, w1.difference
    assert_equal 1, w2.difference
    assert_equal -13, w3.difference
    
    w2.destroy
    w3.reload
    assert_equal -12, w3.difference
    w1.destroy
    w3.reload
    assert_equal 0, w3.difference

    w1 = create_kg_weight(Date.today, 10)
    w2 = create_kg_weight(Date.today + 1.day, 20)
    w3 = create_kg_weight(Date.today + 2.days, 5)
    assert_equal 0, w1.difference
    assert_equal 10, w2.difference
    assert_equal -15, w3.difference
  end

  def test_should_update
    w = create_lbs_weight(Date.today, 10, 11)
    assert !w.new_record?
    assert_equal Date.today, w.taken_on
    assert_equal 10, w.stone
    assert_equal 11, w.lbs
    w.update_attributes(:taken_on => Date.today + 1.day, :stone => 8, :lbs => 9)
    w.reload
    assert_equal Date.today + 1.day, w.taken_on
    assert_equal 8, w.stone
    assert_equal 9, w.lbs

    w = create_kg_weight(Date.today, 20)
    assert !w.new_record?
    assert_equal Date.today, w.taken_on
    assert_equal 20, w.weight
    w.update_attributes(:taken_on => Date.today + 1.day, :weight => 40)
    w.reload
    assert_equal Date.today + 1.day, w.taken_on
    assert_equal 40, w.weight
  end

  def test_should_destroy
    w = create_kg_weight(Date.today, 20)
    w.destroy
    assert_raise(ActiveRecord::RecordNotFound) {Weight.find(w.id)}
  end
end
