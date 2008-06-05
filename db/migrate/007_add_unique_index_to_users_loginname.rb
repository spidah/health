class AddUniqueIndexToUsersLoginname < ActiveRecord::Migration
  def self.up
    add_index     :users,     :loginname,     :unique => true
  end

  def self.down
    remove_index  :users,     :loginname
  end
end
