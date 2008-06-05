class AddDifferenceColumnToTargetWeightsTable < ActiveRecord::Migration
  def self.up
    add_column :target_weights, :difference, :integer, :default => 0
  end

  def self.down
    remove_column :target_weights, :difference
  end
end
