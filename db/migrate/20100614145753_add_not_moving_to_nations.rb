class AddNotMovingToNations < ActiveRecord::Migration
  def self.up
    add_column :nations, :not_moving, :boolean
  end

  def self.down
    remove_column :nations, :not_moving
  end
end
