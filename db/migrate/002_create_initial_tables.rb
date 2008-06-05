class CreateInitialTables < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string    :loginname
      t.string    :email
      t.string    :gender,              :default => 'm'
      t.date      :dob
      t.integer   :timezone,            :default => 0
      t.boolean   :isdst,               :default => false
      t.string    :weight_units,        :default => 'lbs'
      t.string    :measurement_units,   :default => 'inches'
      t.boolean   :admin,               :default => false
      t.date      :created_on
      t.datetime  :last_login
    end

    create_table :weights do |t|
      t.integer   :user_id
      t.date      :taken_on
      t.integer   :weight,              :default => 0
      t.integer   :difference,          :default => 0
    end
    add_index     :weights,             :user_id

    create_table :target_weights do |t|
      t.integer   :user_id
      t.date      :created_on
      t.date      :achieved_on
      t.integer   :weight,              :default => 0
    end

    create_table :measurements do |t|
      t.integer   :user_id
      t.date      :taken_on
      t.string    :location
      t.integer   :measurement,         :default => 1
      t.integer   :difference,          :default => 0
    end
    add_index     :measurements,        :user_id
  end

  def self.down
    remove_index  :weights,             :user_id
    remove_index  :measurements,        :user_id

    drop_table    :users
    drop_table    :weights
    drop_table    :target_weights
    drop_table    :measurements
  end
end
