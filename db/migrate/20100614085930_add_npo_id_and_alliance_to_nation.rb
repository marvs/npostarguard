class AddNpoIdAndAllianceToNation < ActiveRecord::Migration
  def self.up
    add_column :nations, :npo_id, :integer
    add_column :nations, :alliance, :string
  end

  def self.down
    remove_column :nations, :alliance
    remove_column :nations, :npo_id
  end
end
