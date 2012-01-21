class City < ActiveRecord::Base
  belongs_to :region
  has_many :branches
  has_many :entries
  
end
