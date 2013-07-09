class AddCoordinateGroupIdToMasterCoordinate < ActiveRecord::Migration
  def self.up
    add_column :master_coordinates, :coordinate_group_id, :integer
  end

  def self.down
    remove_column :master_coordinates, :coordinate_group_id
  end
end
