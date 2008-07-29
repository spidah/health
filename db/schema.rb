# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080729201122) do

  create_table "activities", :force => true do |t|
    t.string  "name"
    t.string  "type"
    t.integer "duration", :default => 0
    t.integer "calories", :default => 0
  end

  create_table "exercises", :force => true do |t|
    t.integer "activity_id"
    t.string  "activity_name"
    t.string  "activity_type"
    t.integer "duration",      :default => 0
    t.integer "calories",      :default => 0
    t.date    "taken_on"
  end

  create_table "food_items", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.integer "food_id"
    t.integer "meal_id"
    t.integer "calories",    :default => 0
    t.integer "quantity",    :default => 1
  end

  create_table "foods", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.string  "weight"
    t.string  "manufacturer"
    t.string  "category"
    t.integer "fat",          :default => 0
    t.integer "protein",      :default => 0
    t.integer "carbs",        :default => 0
    t.integer "calories",     :default => 0
    t.integer "user_id"
  end

  add_index "foods", ["user_id"], :name => "index_foods_on_user_id"

  create_table "meals", :force => true do |t|
    t.string  "name"
    t.integer "user_id"
    t.integer "total_calories", :default => 0
    t.date    "created_on"
  end

  add_index "meals", ["user_id"], :name => "index_meals_on_user_id"

  create_table "measurements", :force => true do |t|
    t.integer "user_id"
    t.date    "taken_on"
    t.string  "location"
    t.integer "measurement", :default => 1
    t.integer "difference",  :default => 0
  end

  add_index "measurements", ["user_id"], :name => "index_measurements_on_user_id"

  create_table "news_items", :force => true do |t|
    t.text "title"
    t.text "body"
    t.date "posted_on"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.binary  "server_url"
    t.string  "handle"
    t.binary  "secret"
    t.integer "issued"
    t.integer "lifetime"
    t.string  "assoc_type"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"

  create_table "target_weights", :force => true do |t|
    t.integer "user_id"
    t.date    "created_on"
    t.date    "achieved_on"
    t.integer "weight",      :default => 0
    t.integer "difference",  :default => 0
  end

  create_table "user_logins", :force => true do |t|
    t.string  "openid_url"
    t.integer "user_id"
    t.integer "linked_to",                      :default => 0
    t.string  "crypted_password", :limit => 40
    t.string  "salt",             :limit => 40
  end

  add_index "user_logins", ["openid_url"], :name => "index_user_logins_on_openid_url"

  create_table "users", :force => true do |t|
    t.string   "loginname"
    t.string   "email"
    t.string   "gender",               :default => "m"
    t.date     "dob"
    t.string   "timezone",             :default => ""
    t.string   "weight_units",         :default => "lbs"
    t.string   "measurement_units",    :default => "inches"
    t.boolean  "admin",                :default => false
    t.date     "created_on"
    t.datetime "last_login"
    t.boolean  "profile_targetweight", :default => false
    t.boolean  "profile_weights",      :default => false
    t.boolean  "profile_measurements", :default => false
    t.boolean  "profile_meals",        :default => false
    t.boolean  "profile_exercise",     :default => false
    t.text     "profile_aboutme"
  end

  add_index "users", ["loginname"], :name => "index_users_on_loginname", :unique => true

  create_table "weights", :force => true do |t|
    t.integer "user_id"
    t.date    "taken_on"
    t.integer "weight",     :default => 0
    t.integer "difference", :default => 0
  end

  add_index "weights", ["user_id"], :name => "index_weights_on_user_id"

end
