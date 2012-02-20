class Profile < ActiveRecord::Base
  attr_accessible :user_id, :company_id, :branch_id, :first_name, :last_name, 
  :rank_id, :phone, :fax, :birthdate

  before_save :strip_blanks
  
  belongs_to :user
  belongs_to :company
  belongs_to :branch
  belongs_to :rank
  
  default_scope includes(:company)
  
  validates_presence_of :company, :branch_id, :first_name, :last_name, :phone, :birthdate
  
  def to_s
    [first_name, last_name].join(" ") 
  end  
  
  def shortname
    [first_name[0], last_name].join(" ")
  end
  
  private
  def strip_blanks
    self.first_name = self.first_name.strip.titleize
    self.last_name = self.last_name.strip.titleize
  end
end
