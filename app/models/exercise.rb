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

  def self.get_latest_date
    latest = first(:select => 'taken_on', :order => 'taken_on DESC')
    latest ? latest.taken_on : nil
  end

  def self.get_count(date)
    count('id', :conditions => {:taken_on => date})
  end

  def self.calories_for_day(date)
    sum('calories', :conditions => {:taken_on => date}) / 100
  end

  def self.duration_for_day(date)
    sum('duration', :conditions => {:taken_on => date}) / 100
  end

  protected
    def after_find
      self[:duration] /= 100 if self[:duration]
      self[:calories] /= 100 if self[:calories]
    end

    def before_save
      self[:duration] *= 100
      self[:calories] *= 100
    end

    def validate
      errors.add(:duration, 'Please enter a valid duration for the exercise.') if self[:duration].to_i <= 0
    end
end
