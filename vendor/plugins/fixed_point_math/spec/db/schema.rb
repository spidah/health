ActiveRecord::Schema.define(:version => 0) do
  create_table :items, :force => true do |t|
    t.string :name
    t.integer :price
  end
end