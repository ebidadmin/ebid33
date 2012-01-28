class LineItem < ActiveRecord::Base
  belongs_to :entry, counter_cache: true
  belongs_to :car_part
  belongs_to :order
  has_many :bids, dependent: :destroy
  # has_one :order, through: :bid
  
  scope :declined, where("status IN  ('Declined', 'Expired')")  
  scope :with_bids, where('line_items.bids_count > 0')

  STATUS_TAGS = %w(Online Additional Relisted For-Decision New PO PO Released For-Delivery Delivered Paid Closed Expired) 
  def part_name
	  car_part.name
	end

	def is_online
	  status == 'Online' || status == 'Additional' || status == 'Relisted'  
	end
	
	def can_be_ordered
    status == "For-Decision"
  end
  
  def status_color
    case status
    when 'Online' then 'notice'
    when 'Additional' then 'notice'
    when 'Relisted' then 'notice'
    when 'For-Decision' then 'highlight'
    when 'New PO' then 'success'
    when 'PO Released' then 'success'
    when 'For-Delivery' then 'success'
    when 'Delivered' then 'success'
    when 'Paid' then 'success'
    when 'Closed' then 'success'
    when 'Expired' then 'warning'
    when 'Declined' then 'warning'
    when 'Cancelled by admin' then 'black'
    when 'Cancelled by buyer' then 'black'
    when 'Cancelled by seller' then 'black'
    else nil
    end
  end
	
end
