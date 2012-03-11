class City < ActiveRecord::Base
  attr_accessible :name, :region_id, :user_id
  
  belongs_to :region
  has_many :branches
  has_many :cart_entries
  has_many :entries
  
  belongs_to :user
  # delegate :name, to: :region
  
  validates_presence_of :name, :region_id
  
  def to_s
    name
  end
end
