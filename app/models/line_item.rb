class LineItem < ActiveRecord::Base
  belongs_to :entry, counter_cache: true
  belongs_to :car_part
  has_many :bids, dependent: :destroy
    
  def part_name
	  car_part.name
	end

	def is_online
	  status == 'Online' || status == 'Additional' || status == 'Relisted'  
	end
end
