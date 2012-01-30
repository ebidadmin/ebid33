class Order < ActiveRecord::Base
  attr_accessible :user_id, :company_id, :entry_id, :ref_no, :ref_name, :deliver_to, :address1, :address2, 
  :contact_person, :phone, :fax, :instructions, :status, :buyer_ip, :items_count, :order_total, 
  :seller_id, :seller_confirmation, :created_at, :confirmed, :delivered, :due_date, :paid_temp, 
  :paid, :cancelled, :ratings_count
  
  belongs_to :user
  belongs_to :seller, class_name: "User", foreign_key: :seller_id
  belongs_to :entry, counter_cache: true
  belongs_to :company
  has_one :branch, through: :user
  has_many :bids
  has_many :line_items
  has_many :messages
  
  validates_presence_of :deliver_to#, :address1, :phone
  
  # default_scope includes(:user, :seller, :bids => [:line_item => :car_part]).order('created_at DESC')
  default_scope order('created_at DESC')
  scope :recent, where(status: ['PO Released', 'New', 'For-Delivery'])
  scope :delivered, where(status: 'Delivered')
  scope :paid, where(status: 'Paid')
  
  scope :not_cancelled, where('orders.status NOT LIKE ?', "%Cancelled%") # used in Orders#Show
  
  def populate(user, ip, bidder, bids)
    self.company_id = user.company.id
    self.buyer_ip = ip
    self.seller_id = bidder
    self.order_total = bids.collect(&:total).sum 
    self.items_count = self.items_count + bids.count
  end
  
  def status_date
    case status
    when 'For-Delivery' then confirmed
    when 'Delivered' then delivered
    when 'Paid' then paid
    when 'Closed' then paid
    else created_at
    end
  end
  
  def status_color
    case status
    when 'New PO' then 'success'
    when 'PO Released' then 'success'
    when 'For-Delivery' then 'success'
    when 'Delivered' then 'success'
    when 'Paid' then 'success'
    when 'Closed' then 'success'
    else 'warning'
    end
  end
  
  def is_not_yet_paid
    due_date.present? && paid.nil?
  end
  
  # time computations
  def delivery_time
    (delivered - confirmed.to_date).to_i 
  end
  
  def days_overdue # used in ORDERS#INDEX, SHOW
    (Date.today - due_date).to_i - 1
  end
  
  def paid_but_overdue # used in ORDERS#SHOW
    (paid - due_date).to_i 
  end
  
  
  
  
end
