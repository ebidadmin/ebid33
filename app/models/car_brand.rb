class CarBrand < ActiveRecord::Base  
  attr_accessible :car_origin_id, :name

  belongs_to :car_origin
  has_many :car_models, dependent: :destroy
  has_many :car_variants, dependent: :destroy
  has_many :entries
  has_many :bids
  
  
  validates_presence_of :name
end
