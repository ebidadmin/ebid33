class Fee < ActiveRecord::Base
  belongs_to :entry
  belongs_to :line_item
  belongs_to :buyer, :class_name => "User", :foreign_key => "buyer_id"
  belongs_to :seller, :class_name => "User", :foreign_key => "seller_id"
  belongs_to :buyer_company, :class_name => "Company", :foreign_key => "buyer_company_id"
  belongs_to :seller_company, :class_name => "Company", :foreign_key => "seller_company_id"
  
  default_scope order('created_at DESC')
end
