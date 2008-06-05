class CreateUserLogins < ActiveRecord::Migration
  def self.up
    create_table :user_logins do |t|
      t.string    :openid_url
      t.integer   :user_id
      t.integer   :linked_to,               :default => 0
      t.string    :crypted_password,        :limit => 40
      t.string    :salt,                    :limit => 40
    end
    add_index     :user_logins,             :openid_url
  end

  def self.down
    drop_index    :user_logins,             :openid_url
    drop_table    :user_logins
  end
end
