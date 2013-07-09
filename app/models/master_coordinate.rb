class MasterCoordinate < ActiveRecord::Base
  attr_accessible :rank, :latitude, :longitude, :user_id, :nation_id, :coordinate_group_id
  
  belongs_to :updated_by, :class_name => "User", :foreign_key => :user_id
  belongs_to :nation
  belongs_to :coordinate_group
  
  validates_presence_of :rank, :latitude, :longitude
  validates_numericality_of :latitude, :longitude
  validate :nation_has_one_coordinate_only, :unless => Proc.new { |n| n.nation_id.blank? }
  
  def nation_has_one_coordinate_only
    if nation_id_changed? and nation.master_coordinate
      errors.add_to_base("That Nation already has an assigned Master Coordinate!")
    end
  end
  
end
