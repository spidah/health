class CreateNewsItems < ActiveRecord::Migration
  def self.up
    create_table :news_items do |t|
      t.text    :title
      t.text    :body
      t.date    :posted_on
    end
  end

  def self.down
    drop_table  :news_items
  end
end
