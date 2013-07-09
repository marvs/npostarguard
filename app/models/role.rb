class Role < ActiveRecord::Base
  attr_accessible :name, :description
  
  # Relations
  has_many :designations
  has_many :users, :through => :designations
  
end
