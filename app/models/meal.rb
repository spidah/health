class Meal < ActiveRecord::Base
  belongs_to :user
  has_many :food_items, :dependent => :delete_all

  validates_presence_of :name, :message => 'Please enter a meal name.'

  def update_calories
    items = food_items.find(:all)
    tc = 0
    items.each {|item| tc += item.calories * item.quantity}
    self[:total_calories] = tc
    save
  end

  def self.find_for_day(date)
    find(:all, :conditions => {:created_on => date})
  end

  def self.get_latest_date
    latest = first(:select => 'created_on', :order => 'created_on DESC')
    latest ? latest.created_on : nil
  end

  def self.get_count(date)
    count('id', :conditions => {:created_on => date})
  end

  def self.calories_for_day(date)
    sum('total_calories', :conditions => {:created_on => date})
  end

  protected
    def after_find
      self[:total_calories] = self[:total_calories] / 100 if self[:total_calories]
    end

    def before_save
      self[:total_calories] = self[:total_calories] * 100
    end
end
