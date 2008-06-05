class AddSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.string    :session_id
      t.text      :data
      t.datetime  :updated_at
    end
    
    add_index     :sessions,   :session_id
  end

  def self.down
    remove_index  :sessions,   :session_id
    drop_table    :sessions
  end
end
