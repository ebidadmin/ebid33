class CartEntry < ActiveRecord::Base
  belongs_to :cart
  belongs_to :car_brand
  belongs_to :car_model
  belongs_to :car_variant
  belongs_to :city
  belongs_to :term
end
