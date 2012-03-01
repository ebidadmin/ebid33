class LineItem < ActiveRecord::Base
  belongs_to :entry, counter_cache: true
  belongs_to :car_part
  belongs_to :order
  has_many :bids, dependent: :destroy
  has_many :fees
  has_one :variance, dependent: :destroy
  
  # default_scope includes(:car_part, :bids)

  scope :fresh, where(status: ['New', 'Edited'])
  scope :online, where(status: ['Online', 'Relisted', 'Additional'])
  scope :declined, where(status: ['Declined', 'Expired'])
  scope :relistable, where(:status => 'No Bids')
  scope :with_bids, where('line_items.bids_count > 0')
  scope :without_bids, where('line_items.bids_count < 1')
  scope :not_cancelled, where('line_items.status NOT LIKE ?', "%Cancelled%") 

  STATUS_TAGS = %w(Online Additional Relisted For-Decision New PO PO Released For-Delivery Delivered Paid Closed Expired) 
  
  delegate :name, to: :car_part
  
  def part_name
	  car_part.name if car_part
	end

	def self.from_cart_item(cart_item, cart_spec)
		li = self.new
		li.quantity = cart_item.quantity
		li.car_part_id = cart_item.car_part_id
		li.specs = cart_spec
		li 
	end 

	def update_for_decision
	  if bids.present?
      update_attribute(:status, "For-Decision")
      bids.update_for_decision
	  else
      update_attribute(:status, "No Bids") 
	  end 
	end
	
	def expire
    if bids.present? #WITH BIDS
      lowest_bid = bids.for_decision.not_cancelled.last
      lowest_bid.expire
      self.update_attribute(:status, "Expired")
    else #WITHOUT BIDS
      update_attribute(:status, "No Bids")
    end
	end

  def is_deleteable
    bids_count < 1
  end
  
	def is_online
	  status == 'Online' || status == 'Relisted' || status == 'Additional'
	end
	
	def can_be_ordered
    status == "For-Decision" || status == "Expired"
  end
  
  def cannot_be_expired
    self.order_id.present? || self.declined_or_expired || self.cancelled
  end
  
  def declined_or_expired 
    status == "Declined" || status == "Expired"
  end
  
  def cancelled
    status.include?('Cancelled')
  end

  def status_color
    case status
    when 'Online', 'Additional', 'Relisted' then 'label-cool'
    when 'For-Decision' then 'highlight'
    when 'New PO', 'PO Released', 'For-Delivery', 'Delivered', 'Paid!', 'Paid', 'Closed' then 'label-success'
    when 'Expired', 'Declined' then 'label-warning'
    when 'Cancelled by admin', 'Cancelled by buyer', 'Cancelled by seller', 'Cancelled' then 'label-black'
    else nil
    end
    # 'black' if status.include?('Cancelled')
  end
	
end
