class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :car_part

  def part_name
	  car_part.name if car_part
	end
end
