class FoodItem < ActiveRecord::Base
  belongs_to :meal

  fixed_point_number_integer :calories

  validates_numericality_of :quantity, :only_integer => true, :greater_than => 0, :message => 'You need a quantity of at least 1.'

  protected

  def after_destroy
    meal.update_calories
  end

  def after_save
    meal.update_calories
  end
end
