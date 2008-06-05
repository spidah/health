class AddProfileSettings < ActiveRecord::Migration
  def self.up
    add_column :users,    :profile_targetweight,    :boolean,     :default => false
    add_column :users,    :profile_weights,         :boolean,     :default => false
    add_column :users,    :profile_measurements,    :boolean,     :default => false
    add_column :users,    :profile_meals,           :boolean,     :default => false
    add_column :users,    :profile_exercise,        :boolean,     :default => false
    add_column :users,    :profile_aboutme,         :text
  end

  def self.down
    remove_column :users, :profile_targetweight
    remove_column :users, :profile_weights
    remove_column :users, :profile_measurements
    remove_column :users, :profile_meals
    remove_column :users, :profile_exercise
    remove_column :users, :profile_aboutme
  end
end
