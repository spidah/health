class Activity < ActiveRecord::Base
  belongs_to :user
  self.inheritance_column = 'unused'

  # only allow these attributes to be changeable
  attr_accessible :name, :type, :duration, :calories

  validates_presence_of :name, :message => 'Please enter a name for the activity.'
  validates_presence_of :type, :message => 'Please select a type for the activity.'
  validates_presence_of :duration, :message => 'Please enter a duration for the activity.'
  validates_presence_of :calories, :message => 'Please enter the calories for the activity.'

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

    def validate
      errors.add(:duration, 'Please enter a valid duration for the activity.') if self[:duration].to_i <= 0
      errors.add(:calories, 'Please enter a valid calorie count for the activity.') if self[:calories].to_i <= 0
    end
end
