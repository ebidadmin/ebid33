class Profile < ActiveRecord::Base
  attr_accessible :user_id, :company_id, :branch_id, :first_name, :last_name, 
  :rank_id, :phone, :fax, :birthdate

  before_save :strip_blanks
  
  belongs_to :user
  belongs_to :company
  belongs_to :branch
  belongs_to :rank
  
  def to_s
    [first_name, last_name].join(" ") 
  end  
  
  private
  def strip_blanks
    self.first_name = self.first_name.strip.titleize
    self.last_name = self.last_name.strip.titleize
  end
end
