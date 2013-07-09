class CreateCoordinateGroups < ActiveRecord::Migration
  def self.up
    create_table :coordinate_groups do |t|
      t.string :name
      t.timestamps
    end
  end
  
  def self.down
    drop_table :coordinate_groups
  end
end
