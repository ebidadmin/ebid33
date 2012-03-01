class CarVariant < ActiveRecord::Base
  belongs_to :car_brand
  belongs_to :car_model
  belongs_to :user, class_name: "User", foreign_key: "creator_id"
  has_many :cart_entries
  has_many :entries
  
  attr_accessible :car_brand_id, :car_model_id, :name, :start_year, :end_year
  attr_accessor :new_model
  
  validates_presence_of :name
  
  
end
