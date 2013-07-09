class CreateMasterCoordinates < ActiveRecord::Migration
  def self.up
    create_table :master_coordinates do |t|
      t.integer :rank
      t.float :latitude, :precision => 6, :scale => 6
      t.float :longitude, :precision => 6, :scale => 6
      t.timestamps
    end
  end
  
  def self.down
    drop_table :master_coordinates
  end
end
