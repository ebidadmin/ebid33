class Branch < ActiveRecord::Base
  attr_accessible :company_id, :name, :address1, :address2, :zip_code, :city_id, :approver_id

  belongs_to :company
  belongs_to :city
  belongs_to :approver, :class_name => "User", :foreign_key => "approver_id"
  
  has_many :profiles
  has_many :users, through: :profiles
  has_many :orders, through: :users
  
  def city_name
    city.name
  end
end
