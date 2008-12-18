class Meal < ActiveRecord::Base
  belongs_to :user
  has_many :food_items, :dependent => :delete_all

  named_scope :for_day, lambda { |date| { :conditions => { :created_on => date } } }

  validates_presence_of :name, :message => 'Please enter a meal name.'

  def update_calories
    items = food_items.find(:all)
    tc = 0
    items.each {|item| tc += item.calories * item.quantity}
    self[:total_calories] = tc
    save
  end

  def self.get_latest_date
    latest = first(:select => 'created_on', :order => 'created_on DESC')
    latest ? latest.created_on : nil
  end

  def self.get_count
    count(:id)
  end

  def self.calories
    sum("total_calories / 100").to_i
  end

  protected

  def after_find
    self[:total_calories] /= 100 if self[:total_calories]
  end

  def before_save
    self[:total_calories] *= 100
  end
end
