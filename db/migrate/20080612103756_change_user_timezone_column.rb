class ChangeUserTimezoneColumn < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.change      :timezone,     :string,      :default => ''
      t.remove      :isdst
    end
  end

  def self.down
    change_table :users do |t|
      t.change      :timezone,     :integer,     :default => 0
      t.boolean     :isdst,                      :default => false
    end
  end
end
