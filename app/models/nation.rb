class Nation < ActiveRecord::Base
  attr_accessible :name, :cn_id, :ruler, :npo_id, :alliance, :not_moving
  
  # Relations
  has_many :starguard_rankings
  has_many :starguards, :through => :starguard_rankings
  has_one :master_coordinate
  
  validates_presence_of :name, :cn_id, :ruler
  validates_numericality_of :cn_id, :only_integer => true, :greater_than => 0, :message => "^CN ID is not valid!"
  validates_numericality_of :npo_id, :only_integer => true, :greater_than => 0, :message => "^NPO Forum ID is not valid!", :unless => Proc.new{ |n| n.npo_id.blank? }
  
  def latest_ranking
    self.starguard_rankings.last
  end
  
  def get_ranking(starguard)
    StarguardRanking.find_by_nation_id_and_starguard_id(self.id, starguard.id)
  end
  
  def get_temp_ranking(starguard)
    val = nil
    starguard.starguard_rankings.each do |rank|
      if rank.nation_id == self.id
        val = rank
      end
    end
    return val
  end
  
  def self.npo_nations
    alliance_equals("New Pacific Order").ascend_by_name
  end
  
  def name_and_ruler
    "#{self.name} (#{self.ruler})"
  end
  
end
