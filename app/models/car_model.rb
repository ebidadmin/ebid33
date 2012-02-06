class CarModel < ActiveRecord::Base
  belongs_to :car_brand
  belongs_to :user, class_name: "User", foreign_key: "creator_id"
  has_many :car_variants, dependent: :destroy
  has_many :cart_entries
  has_many :entries
  
  attr_accessible :car_brand_id, :name, :creator_id
end
