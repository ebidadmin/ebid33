class Branch < ActiveRecord::Base
  belongs_to :company
  belongs_to :city
  belongs_to :user, :class_name => "User", :foreign_key => "approver_id"

  attr_accessible :company_id, :name, :address1, :address2, :zip_code, :city_id, :approver_id
end
