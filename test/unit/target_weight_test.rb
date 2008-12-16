require File.dirname(__FILE__) + '/../test_helper'

class TargetWeightTest < Test::Unit::TestCase
  def setup
    @user_lbs = User.find(users(:spidah).id)
    @user_kg = User.find(users(:jimmy).id)
  end

  def create_lbs_target_weight(stone = nil, lbs = nil)
    @user_lbs.target_weights.create(:stone => stone, :lbs => lbs, :weight_units => 'lbs')
  end

  def create_kg_target_weight(weight = nil)
    @user_kg.target_weights.create(:weight => weight, :weight_units => 'kg')
  end

  def test_should_create_target_weight
    assert_difference(TargetWeight, :count) do
      tw = create_lbs_target_weight(10, 10)
      assert(!tw.new_record?, "#{tw.errors.full_messages.to_sentence}")
    end

    assert_difference(TargetWeight, :count) do
      tw = create_kg_target_weight(50)
      assert(!tw.new_record?, "#{tw.errors.full_messages.to_sentence}")
    end
  end

  def test_should_require_weight
    assert_no_difference(TargetWeight, :count) do
      tw = create_lbs_target_weight
      assert(tw.errors.on(:weight))
    end

    assert_no_difference(TargetWeight, :count) do
      tw = create_kg_target_weight
      assert(tw.errors.on(:weight))
    end
  end

  def test_should_require_valid_weight
    assert_no_difference(TargetWeight, :count) do
      tw = create_lbs_target_weight(0, 0)
      assert(tw.errors.on(:weight))
    end

    assert_no_difference(TargetWeight, :count) do
      tw = create_lbs_target_weight(-10, -10)
      assert(tw.errors.on(:weight))
    end

    assert_no_difference(TargetWeight, :count) do
      tw = create_lbs_target_weight('a', 'a')
      assert(tw.errors.on(:weight))
    end

    assert_no_difference(TargetWeight, :count) do
      tw = create_kg_target_weight(0)
      assert(tw.errors.on(:weight))
    end

    assert_no_difference(TargetWeight, :count) do
      tw = create_kg_target_weight(-10)
      assert(tw.errors.on(:weight))
    end

    assert_no_difference(TargetWeight, :count) do
      tw = create_kg_target_weight('a')
      assert(tw.errors.on(:weight))
    end
  end

  def test_should_format_target_weight
    tw = create_lbs_target_weight(1, 4)
    assert_equal('1 stone 4 lbs', tw.format)

    tw = create_lbs_target_weight(1, 1)
    assert_equal('1 stone 1 lb', tw.format)

    tw = create_kg_target_weight(50)
    assert_equal('50 kg', tw.format)
  end

  def test_should_update_difference
    tw = create_lbs_target_weight(1, 4)
    assert_equal(18, tw.difference)
    w = @user_lbs.weights.build(:stone => 2, :lbs => 0, :weight_units => 'lbs')
    w.taken_on = Date.today
    w.save
    tw.reload
    assert_equal(10, tw.difference)

    w = @user_lbs.weights.build(:stone => 1, :lbs => 8, :weight_units => 'lbs')
    w.taken_on = Date.today + 1.day
    w.save
    tw.reload
    assert_equal(4, tw.difference)
  end

  def test_should_set_achieved_on
    tw = create_lbs_target_weight(1, 4)
    assert_equal(18, tw.difference)
    assert_equal(nil, tw.achieved_on)
    
    w = @user_lbs.weights.build(:stone => 1, :lbs => 3, :weight_units => 'lbs')
    w.taken_on = Date.today
    w.save
    tw.reload
    assert_equal(-1, tw.difference)
    assert_equal(Date.today, tw.achieved_on)
    
    w = @user_lbs.weights.build(:stone => 1, :lbs => 2, :weight_units => 'lbs')
    w.taken_on = Date.today + 1.day
    w.save
    tw.reload
    assert_equal(-2, tw.difference)
    assert_equal(Date.today, tw.achieved_on)
  end

  def test_should_destroy
    tw = create_lbs_target_weight(10, 5)
    tw.destroy
    assert_raise(ActiveRecord::RecordNotFound) {TargetWeight.find(tw.id)}
  end
end
