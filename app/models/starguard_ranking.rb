class StarguardRanking < ActiveRecord::Base
  attr_accessible :nation_id, :starguard_id, :rank, :strength, :messaged_flag, :user_id, :color, :latitude, :longitude
  
  # Relations
  belongs_to :starguard
  belongs_to :nation
  belongs_to :messaged_by, :class_name => "User", :foreign_key => :user_id
  
end
