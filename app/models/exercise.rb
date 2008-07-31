class Exercise < ActiveRecord::Base
  belongs_to :user

  attr_accessible :duration, :calories

  def set_values(params, activity)
    self[:activity_id] = activity.id
    self[:activity_name] = activity.name
    self[:activity_type] = activity.type
    self[:duration] = params["duration"]
    self[:calories] = ((activity.calories.to_f / activity.duration.to_f) * self[:duration]).to_i
  end

  def self.find_for_day(date)
    find(:all, :conditions => {:taken_on => date})
  end

  def self.calories_for_day(date)
    sum('calories', :conditions => {:taken_on => date})
  end

  def self.duration_for_day(date)
    sum('duration', :conditions => {:taken_on => date})
  end
end
