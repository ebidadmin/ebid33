class CarBrand < ActiveRecord::Base  
  belongs_to :car_origin
  has_many :car_models, dependent: :destroy
  has_many :car_variants, dependent: :destroy
  has_many :entries
  
  attr_accessible :car_origin_id, :name
  
  validates_presence_of :name
end
