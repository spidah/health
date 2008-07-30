class CreateExerciseTables < ActiveRecord::Migration
  def self.up
    create_table :exercises do |t|
      t.integer       :user_id, :activity_id
      t.string        :activity_name, :activity_type
      t.integer       :duration, :calories,                   :default => 0
      t.date          :taken_on
    end

    create_table :activities do |t|
      t.integer       :user_id
      t.string        :name, :type
      t.integer       :duration, :calories,                   :default => 0
    end
  end

  def self.down
    drop_table :exercises
    drop_table :activities
  end
end
