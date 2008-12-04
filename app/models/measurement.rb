class Measurement < ActiveRecord::Base
  belongs_to :user

  # only allow these attributes to be changeable
  attr_accessible :measurement, :location, :taken_on

  # validations
  validates_presence_of :taken_on, :message => 'Please pick a valid date.'
  validates_presence_of :location, :message => 'Please enter a valid location.'
  validates_uniqueness_of :location, :scope => [:user_id, :taken_on], :message => 'You have already entered a measurement for this location.'
  validates_numericality_of :measurement, :only_integer => true, :allow_nil => true, :greater_than => 0,
    :message => 'Please enter a valid measurement.'

  def self.get_single_measurements(direction = 'DESC', conditions = nil, limit = nil)
    find(:all, :order => "taken_on #{direction}, location ASC", :conditions => conditions, :limit => limit)
  end

  def self.get_multiple_measurements(direction, condition, limit)
    found_dates = find(:all, :select => 'taken_on', :conditions => condition, :order => "taken_on #{direction}", :group => 'taken_on', :limit => limit)
    return [] if found_dates.size == 0
    dates = found_dates.collect{|date| "'#{date.taken_on}'"}.join(', ')
    find(:all, :conditions => "taken_on IN (#{dates})", :order => 'taken_on DESC, location ASC')
  end

  def self.get_latest_measurements
    latest = find(:first, :order => 'taken_on DESC')
    self.get_single_measurements('DESC', "taken_on = '#{latest.taken_on}'") rescue nil
  end

  def self.find_first(conditions, order = nil)
    find(:first, :order => order ? order : 'taken_on ASC', :conditions => conditions)
  end

  def self.get_latest_date
    find(:first, :select => 'taken_on', :order => 'taken_on DESC').taken_on rescue nil
  end

  def self.get_count(date)
    count('id', :conditions => {:taken_on => date})
  end

  def update_difference
    prev_m = self.user.measurements.find_first(['taken_on < ? AND location = ?', taken_on, location], 'taken_on DESC')

    self[:difference] = prev_m ? measurement - prev_m.measurement : 0

    if location_changed?
      prev_m = self.user.measurements.find_first(['taken_on < ? AND location = ?', taken_on, location], 'taken_on DESC')
      next_m = self.user.measurements.find_first(['taken_on > ? AND location = ?', taken_on, location], 'taken_on ASC')

      if next_m
        next_m.difference = prev_m ? prev_m.measurement - next_m.measurement : 0
        next_m.save
      end
    end
  end

  def update_next_difference
    next_m = self.user.measurements.find_first(['taken_on > ? AND location = ?', taken_on, location], 'taken_on ASC')
    if next_m
      prev_m = frozen? ? self.user.measurements.find_first(['taken_on < ? AND location = ?', taken_on, location], 'taken_on DESC') : self

      next_m.difference = prev_m ? next_m.measurement - prev_m.measurement : 0
      next_m.save
    end

    if location_changed?
      next_m = self.user.measurements.find_first(['taken_on > ? AND location = ?', taken_on, location_was], 'taken_on ASC')

      if next_m
        prev_m = self.user.measurements.find_first(['taken_on < ? AND location = ?', taken_on, location_was], 'taken_on DESC')
        next_m.difference = prev_m ? next_m.measurement - prev_m.measurement : 0
        next_m.save
      end
    end
  end

  protected
    def before_validation
      self[:location] = self[:location].capitalize if self[:location]
    end

    def before_save
      update_difference if location_changed? || measurement_changed?
    end

    def after_save
      update_next_difference if location_changed? || measurement_changed?
    end

    def after_destroy
      update_next_difference
    end
end
