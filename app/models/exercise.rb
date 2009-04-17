class Exercise < ActiveRecord::Base
  belongs_to :user

  fixed_point_number_integer :calories, :duration

  named_scope :for_day, lambda { |date| { :conditions => { :taken_on => date } } }

  named_scope :for_month, lambda { |month|
    { :conditions => ['taken_on >= ? AND taken_on <= ?', month.beginning_of_month, month.end_of_month] }
  }

  validates_numericality_of :duration, :only_integer => true, :greater_than => 0, :message => 'Please enter a duration greater than 0.'

  def set_values(duration, activity)
    self[:activity_id] = activity.id
    self[:activity_name] = activity.name
    self[:activity_type] = activity.type
    self.duration = duration
    self.calories = ((activity.calories.to_f / activity.duration.to_f) * self.duration).to_i
  end

  def self.get_latest_date
    first(:select => 'taken_on', :order => 'taken_on DESC').taken_on rescue nil
  end

  def self.get_count
    count(:id)
  end

  def self.counts
    counts = count(1, :group => :taken_on)
    hash = {}
    counts.each {|count| hash[count[0]] = count[1]}
    hash
  end

  def self.calories
    sum('calories / 100')
  end

  def self.duration
    sum('duration / 100')
  end
end
