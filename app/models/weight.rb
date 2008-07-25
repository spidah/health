class Weight < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  belongs_to :user

  # only allow these attributes to be changeable
  attr_accessor :weight_units, :stone, :lbs, :stop
  attr_accessible :weight, :taken_on, :weight_units, :stone, :lbs

  validates_presence_of :taken_on, :message => 'Please pick a valid date.'
  validates_uniqueness_of :taken_on, :scope => :user_id, :message => 'You have already entered a weight for this day.'

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
    if units == 'lbs' || weight_units == 'lbs'
      w = ''
      w += "#{stone.to_s} stone " if stone > 0
      w += pluralize(lbs, 'lb')
    else
      "#{self[:weight].to_s} kg"
    end
  end

  def self.find_first(conditions, order = nil)
    find(:first, :order => order ? order : 'taken_on ASC', :conditions => conditions)
  end

  def self.get_latest
    find(:first, :order => 'taken_on DESC')
  end

  def self.get_for_date(date)
    find(:first, :conditions => {:taken_on => date})
  end

  def self.get_count(date)
    count('id', :conditions => "taken_on = '#{date}'")
  end

  def update_difference
    date = self[:taken_on]
    w = user.weights.find_first(['taken_on < ?', date], 'taken_on DESC')

    # w is the previous weight
    self[:difference] = w ? self[:weight] - w.weight : 0
  end

  def update_next_difference
    date = self[:taken_on]
    w1 = user.weights.find_first(['taken_on > ?', date], 'taken_on ASC')
    return if !w1
    w2 = self.frozen? ? nil : self
    w2 = user.weights.find_first(['taken_on < ?', date], 'taken_on DESC') if !w2

    # w1 is the next weight, w2 is the current/previous weight
    w1.difference = w2 ? w1.weight - w2.weight : 0
    w1.stop = :stop
    w1.save
  end

  protected
    def before_save
      return if stop == :stop
      update_difference
      update_next_difference
    end
    
    def after_save
      return if stop == :stop
      TargetWeight.update_difference(self.user)
    end

    def after_destroy
      TargetWeight.update_difference(self.user)
      update_next_difference
    end

    def before_validation
      self[:weight] = ((stone * 14) + lbs) if weight_units == 'lbs'
    end

    # my validation method
    def validate
      if weight_units == 'lbs'
        errors.add(:weight, 'Please enter a valid weight.') if (stone == 0 and lbs == 0) or (stone < 0 or lbs < 0)
      else
        errors.add(:weight, 'Please enter a valid weight.') if self[:weight].to_i <= 0
      end
    end
end
