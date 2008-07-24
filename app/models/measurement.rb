class Measurement < ActiveRecord::Base
  belongs_to :user

  attr_accessor :stop, :old_location
  # only allow these attributes to be changeable
  attr_accessible :measurement, :location, :taken_on

  # validations
  validates_presence_of :taken_on, :message => 'Please pick a valid date.'
  validates_presence_of :location, :message => 'Please enter a valid location.'
  validates_uniqueness_of :location, :scope => [:user_id, :taken_on], :message => 'You have already entered a measurement for this location.'

  def self.get_single_measurements(direction = 'DESC', conditions = nil, limit = nil)
    find(:all, :order => "taken_on #{direction}, location ASC", :conditions => conditions, :limit => limit)
  end

  def self.get_multiple_measurements(direction, condition, limit)
    found_dates = find(:all, :select => 'taken_on', :conditions => condition, :order => "taken_on #{direction}", :group => 'taken_on', :limit => limit)
    return nil if found_dates.size == 0
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

  def self.get_count(date)
    count('id', :conditions => "taken_on = '#{date}'")
  end

  def update_difference(location, changed_location = nil)
    date = self[:taken_on]
    m = self.user.measurements.find_first(['taken_on < ? AND location = ?', date, location], 'taken_on DESC')

    # m is the previous measurement
    self[:difference] = m ? self[:measurement] - m.measurement : 0

    if changed_location
      m1 = self.user.measurements.find_first(['taken_on < ? AND location = ?', date, location], 'taken_on DESC')
      m2 = self.user.measurements.find_first(['taken_on > ? AND location = ?', date, location], 'taken_on ASC')

      if m2
        m2.difference = m1 ? m1.measurement - m2.measurement : 0
        m2.stop = :stop
        m2.save
      end
    end
  end

  def update_next_difference(location, changed_location = nil)
    date = self[:taken_on]
    m1 = self.user.measurements.find_first(['taken_on > ? AND location = ?', date, location], 'taken_on ASC')
    if m1
      m2 = self.frozen? || (location != self[:location]) ? nil : self
      m2 = self.user.measurements.find_first(['taken_on < ? AND location = ?', date, location], 'taken_on DESC') if !m2

      # m1 is the next measurement, m2 is the current or previous measurement
      m1.difference = m2 ? m1.measurement - m2.measurement : 0
      m1.stop = :stop
      m1.save
    end

    if changed_location
      m1 = self.user.measurements.find_first(['taken_on > ? AND location = ?', date, changed_location], 'taken_on ASC')

      if m1
        m2 = self.user.measurements.find_first(['taken_on < ? AND location = ?', date, changed_location], 'taken_on DESC')
        m1.difference = m2 ? m1.measurement - m2.measurement : 0
        m1.stop = :stop
        m1.save
      end
    end
  end

  protected
    def before_validation
      self[:location] = self[:location].capitalize if self[:location]
    end

    def after_find
      @old_location = self[:location]
    end

    def before_save
      return if stop == :stop
      update_difference(self[:location], @old_location != self[:location] ? @old_location : nil)
      update_next_difference(self[:location], @old_location != self[:location] ? @old_location : nil)
    end

    def after_save
      update_next_difference(@old_location) if !@old_location.blank? && @old_location != self[:location]
      @old_location = self[:location]
    end

    def after_destroy
      update_next_difference(self[:location])
    end

    # my validation method
    def validate
      errors.add(:measurement, 'Please enter a valid measurement.') if self[:measurement].to_i <= 0
    end
end
