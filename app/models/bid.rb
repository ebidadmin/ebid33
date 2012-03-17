class Bid < ActiveRecord::Base
  
  attr_accessible :user_id, :entry_id, :line_item_id, :car_brand_id, :amount, :quantity, :total, 
  :bid_type, :bid_speed, :lot, :status, :ordered, :order_id, :delivered, :paid, :declined, :expired

  belongs_to :user, counter_cache: true
  belongs_to :entry, counter_cache: true
  belongs_to :line_item, counter_cache: true
  belongs_to :car_brand
  belongs_to :order
  
  has_many :fees
  has_one :variance, dependent: :destroy

  validates :amount, numericality: { greater_than: 1 }, presence: true
  
  STATUS_TAGS = %w(New Updated For-Decision For-Delivery Delivered Overdue Paid Closed Lose Declined Dropped Cancelled)

  default_scope includes(:user).order('amount DESC').order('bid_speed DESC')
  scope :by_user, lambda { |user| where(user_id: user) }

  # scope :cancelled, where('bids.status LIKE ?', "%Cancelled%") 
  scope :online, where(status: ['New', 'Submitted', 'Updated'])
  scope :for_decision, where(status: 'For-Decision')
  scope :cancelled, where('bids.status LIKE ?', "%Cancelled%") 
  scope :not_cancelled, where('bids.status NOT LIKE ?', "%Cancelled%") 
  scope :with_orders, where('bids.order_id IS NOT NULL')
  
  scope :orig, where(:bid_type => 'original')
  scope :rep, where(:bid_type => 'replacement')
  scope :surp, where(:bid_type => 'surplus')
  
  def self.populate(user, entry, line_item, amount, type)
    nb = user.bids.build
		nb.entry_id = entry.id
		nb.line_item_id = line_item.id
		nb.amount = amount
		nb.quantity = line_item.quantity
		nb.total = amount.to_f * line_item.quantity.to_i
    nb.bid_type = type
    nb.car_brand_id = entry.car_brand_id
    nb.bid_speed = nb.compute_bid_speed  
    nb  
  end  

  def compute_bid_speed
    if entry.status == 'Relisted' || entry.status == 'Additional' || entry.status == 'Re-bidding'
      bid_speed = (Time.now - entry.relisted).to_i
    else
      bid_speed = (Time.now - entry.online).to_i
    end
  end
  
  def repopulate(current_user, amount, qty)
    if user != current_user
      update_attributes(user_id: current_user.id, amount: amount, total: amount.to_f * qty, status: 'Updated')
    else
      update_attributes(amount: amount, total: amount.to_f * qty, status: 'Updated')
    end
  end
  
  def process_order(order, qty)
    self.update_attributes(
      status: "New PO", quantity: qty, total: self.amount * qty, 
      ordered: Date.today, order_id: order.id, declined: nil, expired: nil)
    if line_item.declined_or_expired # if Order is due to reactivation, reverse the decline fee and update the bid
      if line_item.fees.present?
        orig_fee ||= line_item.fees.last
        orig_fee.reverse
        orig_fee.bid.update_attribute(:status, 'Dropped') unless orig_fee.bid == self
      end
    else 
      self.update_peer_bids(line_item)  
    end
    line_item.update_attributes(status: "New PO", order_id: order.id)
  end
  
  def process_cancellation
    update_attribute(:status, "Cancelled")
    line_item.update_attribute(:status, "Cancelled")
  end
  
  def update_peer_bids(line_item)
    peer_bids = Bid.where(line_item_id: line_item, status: 'For-Decision').where("bid_type != ?", self.bid_type)
    peer_bids.update_all(status: "Dropped", ordered: nil, order_id: nil, delivered: nil, paid: nil, declined: nil)
  end

  def self.update_for_decision
    self.not_cancelled.group_by(&:bid_type).each do |t, bids|
      lo = bids[-1]
      others = bids[0..-2]
      lo.update_attribute(:status, "For-Decision")
      others.each { |b| b.update_attribute(:status, "Lose") } if others.present?
    end
  end

  def expire
    self.update_attributes(status: "Declined", declined: Time.now, expired: Time.now)
    self.update_peer_bids(line_item)
    Fee.compute(self, "Declined") if fees.for_decline.blank?
  end
  
  def tag_payment(order)
    self.update_attributes(status: 'Paid', paid: order.paid)
    line_item.update_attribute(:status, 'Paid')
    Fee.compute(self, 'Paid', order.id) if fees.for_order.blank? 
  end
  
  def cancelled?
    status.include?('Cancelled')
  end

  def online? # used in Seller#Show to allow deletion of bids
    status == 'Submitted' || status == 'New' || status == 'Updated' || status == 'Re-bidding'
  end
  
  def expired?
    status == 'Expired' || status == 'Declined'
  end
  
  def orig?
    bid_type == 'original'
  end
  
  def rep?
    bid_type == 'replacement'
  end
  
  def surp?
    bid_type == 'surplus'
  end
  
  def status_color
    color = case status
    when 'For-Decision' then 'label-highlight'
    when 'New PO', 'PO Released', 'For-Delivery', 'Delivered', 'Paid!', 'Paid', 'Closed' then 'label-success'
    when 'Expired', 'Declined' then 'label-warning'
    when 'Dropped' then 'label-highlight cancelled'
    else nil
    end
    color = 'label-black' if self.cancelled?
    "label #{color}" unless online?
  end
  
  def status_color_for_buyer
    if self.cancelled?
      "label label-black"
    elsif self.expired?
      "label label-warning"
    elsif order
      "label label-success"
    end
  end
  
end
