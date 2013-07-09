class CreateStarguards < ActiveRecord::Migration
  def self.up
    create_table :starguards do |t|
      t.string :notes
      t.integer :user_id
      t.string :alliance
      t.float :center_latitude, :precision => 6, :scale => 6
      t.float :center_longitude, :precision => 6, :scale => 6
      t.timestamps
    end
  end
  
  def self.down
    drop_table :starguards
  end
end
