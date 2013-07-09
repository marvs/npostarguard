class AddNationIdToMasterCoordinate < ActiveRecord::Migration
  def self.up
    add_column :master_coordinates, :nation_id, :integer
  end

  def self.down
    remove_column :master_coordinates, :nation_id
  end
end
