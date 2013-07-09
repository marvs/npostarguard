class CoordinateGroup < ActiveRecord::Base
  attr_accessible :name
  has_many :master_coordinates
  
  def compliant_message(starguard)
    total_count = 0
    compliant = 0
    non_compliant = 0
    self.master_coordinates.each do |mc|
      if mc.nation and mc.nation.get_ranking(starguard)
        total_count += 1
        if Starguard.correct_coordinate(mc.latitude, mc.nation.get_ranking(starguard).latitude) and Starguard.correct_coordinate(mc.longitude, mc.nation.get_ranking(starguard).longitude)
          compliant += 1
        else
          non_compliant += 1
        end
      end
    end
    percentage = (compliant.to_f/total_count.to_f) * 100
    "Compliant Nations: #{compliant}/#{total_count} (#{percentage}%)"
  end 
  
end
