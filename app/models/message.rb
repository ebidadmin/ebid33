class Message < ActiveRecord::Base
  attr_accessible :user_id, :user_type, :alias, :user_company_id, :receiver_id, :receiver_company_id, 
  :entry_id, :order_id, :message, :open, :ancestry
  
  has_ancestry
  
  belongs_to :entry
  belongs_to :order
  belongs_to :user
  belongs_to :receiver, :class_name => "User", :foreign_key => "receiver_id"
  belongs_to :user_company, :class_name => "Company", :foreign_key => "user_company_id"
  belongs_to :receiver_company, :class_name => "Company", :foreign_key => "receiver_company_id"

  scope :open, where(:open => true)
  scope :closed, where(:open => false)
  
  RANDOM_NUMBERS = (1..20)
  
  # default_scope includes([:user => :company], [:receiver => :company]).order('created_at DESC')

  def generate_random_alias(user)
    
  end
  
  def user_signature
    "#{user_type.titleize} ##{user_id} said:"
  end
end
