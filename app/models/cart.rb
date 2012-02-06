class Cart < ActiveRecord::Base
  attr_accessible :user_id
  
  belongs_to :user
  has_one :cart_entry, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  
  def add(car_part)
    items = cart_items.where(car_part_id: car_part)
    
    if items.size < 1
      ci = cart_items.create(car_part_id: car_part,
        :quantity => 1,
        :specs => "")
    else
      ci = items.first
      ci.update_attribute(:quantity, ci.quantity + 1)
    end
    ci
  end
  
  def remove(car_part)
    ci = cart_items.find_by_car_part_id(car_part)
    
    if ci.quantity > 1
      ci.update_attribute(:quantity, ci.quantity - 1)
    else
      CartItem.destroy(ci.id)
    end
    ci
  end
  
end
