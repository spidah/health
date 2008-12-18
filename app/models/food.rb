class Food < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :name, :message => 'Please enter a name for the food.'
  validates_numericality_of :fat, :only_integer => true, :greater_than_or_equal_to => 0, :message => 'Please enter a valid fat value.'
  validates_numericality_of :protein, :only_integer => true, :greater_than_or_equal_to => 0, :message => 'Please enter a valid protein value.'
  validates_numericality_of :carbs, :only_integer => true, :greater_than_or_equal_to => 0, :message => 'Please enter a valid carbohydrate value.'
  validates_numericality_of :calories, :only_integer => true, :greater_than_or_equal_to => 0, :message => 'Please enter a valid calories value.'

  def self.pagination(page, sort = nil, dir = 'ASC')
    paginate :page => page, :per_page => 50, :order => sort ? "#{sort} #{dir}" : 'id ASC'
  end

  def fat
    @fat ||= self[:fat].to_f / 100
  end

  def fat=(value)
    self[:fat] = (value.to_f * 100).to_i
    @fat = value.to_f
  end

  def protein
    @protein ||= self[:protein].to_f / 100
  end

  def protein=(value)
    self[:protein] = (value.to_f * 100).to_i
    @protein = value.to_f
  end

  def carbs
    @carbs ||= self[:carbs].to_f / 100
  end

  def carbs=(value)
    self[:carbs] = (value.to_f * 100).to_i
    @carbs = value.to_f
  end

  def calories
    @calories ||= self[:calories] / 100
  end

  def calories=(value)
    self[:calories] = value.to_i * 100
    @calories = value.to_i
  end

  protected

  def after_save
    if name_changed? || description_changed? || calories_changed?
      @items = FoodItem.find(:all, :conditions => {:food_id => self[:id]})
      if @items.size > 0
        for item in @items do
          item.calories = calories
          item.name = self[:name]
          item.description = self[:description]
          item.save
        end
      end
    end
  end
end
