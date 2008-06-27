class AddFoodTables < ActiveRecord::Migration
  def self.up
    create_table :foods do |t|
      t.string        :name, :description, :weight, :manufacturer, :category
      t.integer       :fat, :protein, :carbs, :calories,                                  :default => 0
      t.integer       :user_id
    end
    add_index         :foods,             :user_id

    create_table :food_items do |t|
      t.string        :name, :description
      t.integer       :food_id, :meal_id
      t.integer       :calories,                                                          :default => 0
      t.integer       :quantity,                                                          :default => 1
    end

    create_table :meals do |t|
      t.string        :name
      t.integer       :user_id
      t.integer       :total_calories,                                                    :default => 0
      t.date          :created_on
    end
    add_index         :meals,             :user_id
  end

  def self.down
    remove_index      :foods,             :user_id
    remove_index      :meals,             :user_id
    drop_table        :foods
    drop_table        :food_items
    drop_table        :meals
  end
end
