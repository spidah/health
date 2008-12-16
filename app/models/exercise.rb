class Exercise < ActiveRecord::Base
  belongs_to :user

  named_scope :for_day, lambda { |date| { :conditions => { :taken_on => date } } }

  validates_numericality_of :duration, :only_integer => true, :greater_than => 0, :message => 'Please enter a duration greater than 0.'

  def set_values(duration, activity)
    self[:activity_id] = activity.id
    self[:activity_name] = activity.name
    self[:activity_type] = activity.type
    self.duration = duration
    self.calories = ((activity.calories.to_f / activity.duration.to_f) * self.duration).to_i
  end

  def calories
    @calories ||= self[:calories] / 100
  end

  def calories=(value)
    self[:calories] = value.to_i * 100
    @calories = value.to_i
  end

  def duration
    @duration ||= self[:duration] / 100
  end

  def duration=(value)
    self[:duration] = value.to_i * 100
    @duration = value.to_i
  end

  def self.get_latest_date
    first(:select => 'taken_on', :order => 'taken_on DESC').taken_on rescue nil
  end

  def self.get_count
    count(:id)
  end

  def self.calories
    sum('calories / 100')
  end

  def self.duration
    sum('duration / 100')
  end
end
