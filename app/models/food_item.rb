class FoodItem < ActiveRecord::Base
  belongs_to :meal

  validates_numericality_of :quantity, :only_integer => true, :greater_than => 0, :message => 'You need a quantity of at least 1.'

  def calories
    @calories ||= self[:calories] / 100
  end

  def calories=(value)
    self[:calories] = value.to_i * 100
    @calories = value.to_i
  end

  protected

  def after_destroy
    meal.update_calories
  end

  def after_save
    meal.update_calories
  end
end
