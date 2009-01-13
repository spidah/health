class Weight < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  belongs_to :user

  named_scope :for_month, lambda { |month|
    { :conditions => ['taken_on >= ? AND taken_on <= ?', month.beginning_of_month, month.end_of_month] }
  }

  # only allow these attributes to be changeable
  attr_accessor :weight_units, :stone, :lbs
  attr_accessible :weight, :weight_units, :stone, :lbs

  validates_presence_of :taken_on, :message => 'Please pick a valid date.'
  validates_uniqueness_of :taken_on, :scope => :user_id, :message => 'You have already entered a weight for this day.'

  # accessor methods for stone and lbs
  def stone
    @stone ||= (weight / 14).to_i
  end

  def stone=(value)
    @stone = value.to_i
  end

  def lbs
    @lbs ||= (weight % 14).to_i
  end

  def lbs=(value)
    @lbs = value.to_i
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

  def self.counts
    counts = count(1, :group => :taken_on)
    hash = {}
    counts.each {|count| hash[count[0]] = count[1]}
    hash
  end

  def update_difference
    w = user.weights.find_first(['taken_on < ?', taken_on], 'taken_on DESC')

    # w is the previous weight
    self[:difference] = w ? self[:weight] - w.weight : 0
  end

  def update_next_difference
    next_w = user.weights.find_first(['taken_on > ?', taken_on], 'taken_on ASC')
    return if !next_w
    prev_w = self.frozen? ? user.weights.find_first(['taken_on < ?', taken_on], 'taken_on DESC') : self

    next_w.difference = prev_w ? next_w.weight - prev_w.weight : 0
    next_w.save
  end

  def self.cache_existing_weight(session, current_date, invalidate = false)
    if invalidate || current_date != session[:existing_weight_date]
      session[:existing_weight] = nil
      session[:existing_weight_date] = nil
    end

    session[:existing_weight_date] ||= current_date
    session[:existing_weight] ||= begin get_for_date(current_date).id rescue 0 end
  end

  protected
    def before_save
      return if !weight_changed?
      update_difference
      update_next_difference
    end
    
    def after_save
      return if !weight_changed?
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
        errors.add(:weight, 'Please enter a valid weight.') if (stone == 0 && lbs == 0) || (stone < 0 || lbs < 0)
      else
        errors.add(:weight, 'Please enter a valid weight.') if self[:weight].to_i <= 0
      end
    end
end
