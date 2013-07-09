class Starguard < ActiveRecord::Base
  attr_accessible :alliance, :user_id, :notes, :center_latitude, :center_longitude
  
  # Relations
  belongs_to :user
  has_many :starguard_rankings, :dependent => :destroy
  
  def self.correct_coordinate(c1, c2)
    rc1 = Starguard.round_float(c1, 3)
    rc2 = Starguard.round_float(c2, 3)
    rc1 == rc2
  end
  
  def self.round_float(num, x)
    (num * 10**x).round.to_f / 10**x
  end

  def self.ceil_float(num, x)
    (num * 10**x).ceil.to_f / 10**x
  end

  def self.floor_float(num, x)
    (num * 10**x).floor.to_f / 10**x
  end
  
end
