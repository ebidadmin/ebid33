class Company < ActiveRecord::Base
  attr_accessible :name, :nickname, :primary_role, :trial_start, :trial_end, 
  :metering_date, :perf_ratio
  
  belongs_to :primary_role, :class_name => "Role", :foreign_key => "primary_role_id"
  
  has_many :profiles
  has_many :users, through: :profiles
  has_many :branches#, through: :profiles
  has_many :entries
  has_many :orders
  has_many :seller_companies, through: :orders
  has_many :messages
  has_many :user_companies, through: :messages
  has_many :receiver_companies, through: :messages
  has_many :buyer_companies, through: :fees
  has_many :seller_companies, through: :fees
end
