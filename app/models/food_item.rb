class FoodItem < ActiveRecord::Base
  belongs_to :meal

  validates_numericality_of :quantity, :only_integer => true, :greater_than => 0, :message => 'You need a quantity of at least 1.'

  protected
    def after_destroy
      meal.update_calories
    end

    def after_find
      self[:calories] = self[:calories] / 100
    end

    def after_save
      meal.update_calories
    end

    def before_save
      self[:calories] = self[:calories] * 100
    end
end
