class Rating < ActiveRecord::Base
  attr_accessible :order_id, :user_id, :ratee_id, :stars, :review
end
