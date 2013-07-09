class AddUserIdToMasterCoordinates < ActiveRecord::Migration
  def self.up
    add_column :master_coordinates, :user_id, :integer
  end

  def self.down
    remove_column :master_coordinates, :user_id
  end
end
