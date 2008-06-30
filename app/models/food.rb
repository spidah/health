class Food < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :name, :message => 'Please enter a name for the food.'

  def self.pagination(page, sort = nil, dir = 'ASC')
    paginate :page => page, :per_page => 50, :order => sort ? "#{sort} #{dir}" : 'id ASC'
  end

  def fat
    fat_before_type_cast
  end

  def protein
    protein_before_type_cast
  end

  def carbs
    carbs_before_type_cast
  end

  def calories=(new_calories)
    @changed = true if new_calories.to_i != self[:calories]
    self[:calories] = new_calories
  end

  def name=(new_name)
    @changed = true if new_name != self[:name]
    self[:name] = new_name
  end

  def description=(new_description)
    @changed = true if new_description != self[:description]
    self[:description] = new_description
  end

  protected
    def after_find
      self[:fat] = (self[:fat].to_f / 100)
      self[:protein] = (self[:protein].to_f / 100)
      self[:carbs] = (self[:carbs].to_f / 100)
      self[:calories] = self[:calories] / 100
    end

    def before_save
      self[:fat] = (fat_before_type_cast.to_f * 100).to_i
      self[:protein] = (protein_before_type_cast.to_f * 100).to_i
      self[:carbs] = (carbs_before_type_cast.to_f * 100).to_i
      self[:calories] = self[:calories] * 100
    end

    def after_save
      if @changed
        @items = FoodItem.find(:all, :conditions => {:food_id => self[:id]})
        if @items.size > 0
          new_calories = self[:calories] / 100
          for item in @items do
            item.calories = new_calories
            item.name = self[:name]
            item.description = self[:description]
            item.save
          end
        end
      end
    end
end
