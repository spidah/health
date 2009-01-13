class TargetWeight < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  belongs_to :user

  before_validation :convert_weight

  attr_accessor :weight_units, :stone, :lbs
  attr_accessible :weight, :weight_units, :stone, :lbs, :created_on

  # accessor methods for stone and lbs
  def stone
    @stone = self[:weight] / 14 if !@stone
    @stone.to_i
  end

  def lbs
    @lbs = self[:weight] % 14 if !@lbs
    @lbs.to_i
  end

  def format(units = nil)
    if units == 'lbs' || @weight_units == 'lbs'
      w = ''
      w += "#{stone.to_s} stone " if stone > 0
      w += pluralize(lbs, 'lb')
    else
      "#{self[:weight].to_s} kg"
    end
  end

  def self.get_latest
    find :first, :order => 'id DESC'
  end

  def self.update_difference(user)
    if tw = user.target_weights.get_latest
      tw.difference = (cw = user.weights.get_latest) ? cw.weight - tw.weight : tw.weight
      tw.achieved_on = nil if tw.achieved_on && tw.difference > 0
      tw.achieved_on = cw.taken_on if !tw.achieved_on &&  tw.difference <= 0
      tw.save
    end
  end
  
  protected
    def before_create
      self[:difference] = (cw = user.weights.get_latest) ? cw.weight - self[:weight] : self[:weight]
      self[:achieved_on] = cw.taken_on if self[:difference] <= 0
    end

    def convert_weight
      self[:weight] = ((stone * 14) + lbs) if @weight_units == 'lbs'
    end

    # my validation method
    def validate
      if @weight_units == 'lbs'
        errors.add(:weight, 'Please enter a valid weight.') if (stone == 0 and lbs == 0) or (stone < 0 or lbs < 0)
      else
        errors.add(:weight, 'Please enter a valid weight.') if self[:weight].to_i <= 0
      end
    end
end
