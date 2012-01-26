class Bid < ActiveRecord::Base
  attr_accessible :user_id, :entry_id, :line_item_id, :car_brand_id, :amount, :quantity, :total, :bid_type, :bid_speed, :lot, :status, :ordered, :order_id, :delivered, :paid, :declined, :expired

  belongs_to :user, counter_cache: true
  belongs_to :entry, counter_cache: true
  belongs_to :line_item, counter_cache: true
  belongs_to :car_brand
  belongs_to :order

  default_scope includes(:user).order('amount DESC').order('bid_speed DESC')
  scope :by_user, lambda { |user| where(user_id: user) }
  
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
    if entry.status == 'Relisted' || entry.status == 'Additional'
      bid_speed = (Time.now - entry.relisted).to_i
    else
      bid_speed = (Time.now - entry.online).to_i
    end
  end
  

end
