class CreateStarguardRankings < ActiveRecord::Migration
  def self.up
    create_table :starguard_rankings do |t|
      t.integer :nation_id
      t.integer :starguard_id
      t.integer :rank
      t.float :strength, :precision => 8, :scale => 3
      t.string  :color
      t.boolean :messaged_flag
      t.integer :user_id
      t.float :latitude, :precision => 6, :scale => 6
      t.float :longitude, :precision => 6, :scale => 6
      t.timestamps
    end
  end
  
  def self.down
    drop_table :starguard_rankings
  end
end
