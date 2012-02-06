class City < ActiveRecord::Base
  belongs_to :region
  has_many :branches
  has_many :cart_entries
  has_many :entries
  
  def to_s
    name
  end
end
