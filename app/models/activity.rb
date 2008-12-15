class Activity < ActiveRecord::Base
  belongs_to :user
  self.inheritance_column = 'unused'

  # only allow these attributes to be changeable
  attr_accessible :name, :description, :type, :duration, :calories

  validates_presence_of :name, :message => 'Please enter a name.'
  validates_presence_of :type, :message => 'Please select a type.'
  validates_numericality_of :duration, :only_integer => true, :greater_than => 0, :message => 'Please enter a valid duration.'
  validates_numericality_of :calories, :only_integer => true, :greater_than => 0, :message => 'Please enter a valid calorie count.'

  def self.pagination(page, sort = nil, dir = 'ASC')
    paginate :page => page, :per_page => 50, :order => sort ? "#{sort} #{dir}" : 'name ASC'
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
end
