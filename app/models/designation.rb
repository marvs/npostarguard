class Designation < ActiveRecord::Base
  attr_accessible :user_id, :role_id
  
  # Relations
  belongs_to :user
  belongs_to :role

end
