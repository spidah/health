class Meal < ActiveRecord::Base
  belongs_to :user
  has_many :food_items, :dependent => :delete_all

  named_scope :for_day, lambda { |date| { :conditions => { :created_on => date } } }

  named_scope :for_month, lambda { |month|
    { :conditions => ['created_on >= ? AND created_on <= ?', month.beginning_of_month, month.end_of_month] }
  }

  validates_presence_of :name, :message => 'Please enter a meal name.'

  def update_calories
    items = food_items.find(:all)
    tc = 0
    items.each {|item| tc += item.calories * item.quantity}
    self.total_calories = tc
    save
  end

  def total_calories
    @total_calories ||= self[:total_calories] / 100
  end

  def total_calories=(value)
    self[:total_calories] = value.to_i * 100
    @total_calories = value.to_i
  end

  def self.get_latest_date
    first(:select => 'created_on', :order => 'created_on DESC').created_on
  rescue
    nil
  end

  def self.get_count
    count(:id)
  end

  def self.counts
    counts = count(1, :group => :created_on)
    hash = {}
    counts.each {|count| hash[count[0]] = count[1]}
    hash
  end

  def self.calories
    sum("total_calories / 100").to_i
  end
end
