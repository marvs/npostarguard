class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.validate_email_field false
  end
  
  attr_accessible :username, :email, :first_name, :last_name, :alias, :birthdate, :password, :password_confirmation, :role_ids
  
  # Relations
  has_many :designations
  has_many :roles, :through => :designations
  has_many :starguards
  
  validates_presence_of :role_ids, :message => "^Please select at least one Role."
  
  def designate_role_ids(role_ids)
    if role_ids.nil?
      roles.clear
    else
      Role.all.each do |role|
        if role_ids.include?(role.id.to_s)
          roles << role unless roles.include?(role)
        else
          roles.delete(role) if roles.include?(role)
        end
      end
    end
  end
  
  def role_symbols  
    roles.map do |role|  
      role.name.underscore.gsub(/ /,'_').to_sym  
    end  
  end

  def admin?
    admin_role = Role.find_by_id(1)
    self.roles.include?(admin_role)
  end
  
end
