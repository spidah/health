class AddIndexesToTables < ActiveRecord::Migration
  def self.up
    add_index :users,              :id
    add_index :user_logins,        :id
    add_index :weights,            :id
    add_index :measurements,       :id
    add_index :exercises,          :id
    add_index :activities,         :id
    add_index :meals,              :id
    add_index :foods,              :id
    add_index :food_items,         :id
    add_index :target_weights,     :id
  end

  def self.down
    remove_index :users,           :id
    remove_index :user_logins,     :id
    remove_index :weights,         :id
    remove_index :measurements,    :id
    remove_index :exercises,       :id
    remove_index :activities,      :id
    remove_index :meals,           :id
    remove_index :foods,           :id
    remove_index :food_items,      :id
    remove_index :target_weights,  :id
  end
end
