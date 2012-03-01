class Friendship < ActiveRecord::Base
  attr_accessible :company_id, :friend_id
  
  belongs_to :company
  belongs_to :friend, class_name: "Company"
end
