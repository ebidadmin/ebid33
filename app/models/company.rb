class Company < ActiveRecord::Base
  attr_accessible :name, :nickname, :primary_role, :trial_start, :trial_end, 
  :metering_date, :perf_ratio
  
  
  has_many :messages
  has_many :user_companies, through: :messages
  has_many :receiver_companies, through: :messages
  has_many :buyer_companies, through: :fees
  has_many :seller_companies, through: :fees
end
