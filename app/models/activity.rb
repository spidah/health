class Activity < ActiveRecord::Base
  belongs_to :user
  self.inheritance_column = 'unused'

  # only allow these attributes to be changeable
  attr_accessible :name, :description, :type, :duration, :calories

  validates_presence_of :name, :message => 'Please enter a name.'
  validates_presence_of :type, :message => 'Please select a type.'
  validates_presence_of :duration, :message => 'Please enter a duration.'
  validates_presence_of :calories, :message => 'Please enter the calories.'
  validates_numericality_of :duration, :only_integer => true, :greater_than => 0, :message => 'Please enter a valid duration.'
  validates_numericality_of :calories, :only_integer => true, :greater_than => 0, :message => 'Please enter a valid calorie count.'

  def self.pagination(page, sort = nil, dir = 'ASC')
    paginate :page => page, :per_page => 50, :order => sort ? "#{sort} #{dir}" : 'name ASC'
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
end
