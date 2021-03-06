class Order < ActiveRecord::Base
  attr_accessible :user_id, :company_id, :entry_id, :ref_no, :ref_name, :deliver_to, :address1, :address2, 
  :contact_person, :phone, :fax, :instructions, :status, :buyer_ip, :items_count, :order_total, 
  :seller_id, :seller_confirmation, :created_at, :confirmed, :delivered, :due_date, :paid_temp, 
  :paid, :cancelled, :ratings_count, :entry_attributes
  attr_accessor :message

  before_save :clean_up_details
  
  belongs_to :user
  belongs_to :seller, class_name: "User", foreign_key: :seller_id
  belongs_to :entry, counter_cache: true
  accepts_nested_attributes_for :entry, :update_only => true
  belongs_to :company
  belongs_to :seller_company, class_name: "Company", foreign_key: "seller_company_id"
  has_one :branch, through: :user
  has_many :bids
  has_many :line_items
  has_many :messages
  accepts_nested_attributes_for :messages
  has_many :fees
  
  validates_presence_of :deliver_to, :address1, :phone
  validates_presence_of :ref_name, if: :latest_order

  default_scope order('orders.created_at DESC')

  scope :recent, where(status: ['PO Released', 'New PO', 'For-Delivery'])
  scope :delivered, where(status: 'Delivered')
  scope :payment_valid, where('orders.paid IS NOT NULL')
  scope :payment_pending, where(paid: nil)#where('orders.paid IS NULL')
  scope :paid, where(status: 'Paid').payment_valid
  
  scope :cancelled, where('orders.status LIKE ?', "%Cancelled%")
  scope :not_cancelled, where('orders.status NOT LIKE ?', "%Cancelled%") # used in Orders#Show
  
  scope :overdue, delivered.where('orders.due_date < ?', Date.today).payment_pending
  scope :due_now, delivered.where(due_date: Date.today .. 1.week.from_now.to_date).payment_pending
  
  TAGS_FOR_EDIT = ['Pending', 'New PO', 'For-Delivery', 'Delivered', 'Paid', 'Closed', 'Cancelled']
  DAYS_B4_PAYMNT_TAG = Date.today #1.day.ago.to_date
  scope :payment_taggable, where('paid_temp <= ?', DAYS_B4_PAYMNT_TAG)
  
  def self.find_status(status)
   if status == 'new'
      unscoped.where(status: ['New PO', 'PO Released']).order(:created_at)
    elsif status == 'for-delivery'
      unscoped.where(status: 'For-Delivery').order(:confirmed)
    elsif status == 'delivered'
      unscoped.delivered.where('orders.due_date >= ?', Date.today).order(:due_date)
    elsif status == 'overdue'
      unscoped.overdue.order(:delivered)
    elsif status == 'cancelled'
      cancelled
    elsif status == 'unconfirmed'
      where(status: 'Paid').payment_pending
    elsif status == 'paid'
      paid
    elsif status.present?
      where(status: status.titleize)
    else
      scoped
    end
  end

  def self.by_this_seller(company)
     where(seller_company_id: company)
  end
  
  def self.by_this_buyer(user, search_query=nil)
    if search_query.present?
      scoped
    else
      if user.role?(:powerbuyer)
        where(company_id: user.company)
      else
        e = Entry.where(user_id: user)
        where(entry_id: e)
      end
    end
  end
  
  def populate(user, ip, bidder, bids, new_qty)
    self.company_id = user.company.id
    self.buyer_ip = ip
    self.seller_id = bidder.id
    self.seller_company_id = bidder.company.id
    self.items_count = self.items_count + bids.count
    if user.orders << self
      bids.each { |bid| bid.process_order(self, new_qty.fetch(bid.id.to_s)[0].to_i) }
      self.update_attribute(:order_total, bids.collect(&:total).sum) 
    end
  end
  
  # Updates line_items & bids to status = For Delivery, Delivered, or Paid
	def update_associated_status(status)
    line_items.not_cancelled.update_all(status: status)
    active_bids ||= bids.not_cancelled
    if status == "Delivered"
      active_bids.update_all(status: "Delivered", delivered: Date.today)
    elsif status == "Paid"
      active_bids.update_all(status: "Paid", :paid => Date.today)
      active_bids.each { |bid| Fee.compute(bid, status, self.id) } 
    else 
      active_bids.update_all(status: status)
    end
	end
	
	def change_status(status)
	  case status
	  when 'Delivered'
	    update_attributes(status: 'Delivered', delivered: Date.today, due_date: Date.today + entry.term.name.days)
      flash = "Updated the status of the order to <strong>Delivered</strong>.<br>
      Please send your invoice to buyer asap so we can help you <strong>track the payment</strong>.".html_safe
    when 'Paid.'
      if self.update_attributes(status: 'Paid', paid_temp: Date.today)
        Notify.delay.payment_tagged(self, self.entry)#.deliver
        flash = "Updated the status of the order to <strong>Paid</strong>.<br>
        We will notify the seller to confirm your payment.".html_safe
      end
    when 'Paid'
      self.update_attributes(status: 'Paid', paid: Date.today)
      flash = "Updated the status of the order to <strong>Paid</strong>.<br>
      Please rate your buyer to close the order.".html_safe
	  end
	end

  def tag_payment
    self.update_attribute(:paid, self.paid_temp)
    bids.not_cancelled.each { |bid| bid.tag_payment(self) }
    entry.update_status
  end
  
  def status_date
    case status
    when 'For-Delivery' then confirmed
    when 'Delivered' then delivered
    when 'Paid' 
      if paid.present?
        paid
      else
        paid_temp
      end
    when 'Closed' then paid
    else created_at
    end
  end
  
  def status_color
    case status
    when 'New PO', 'PO Released' then 'cool'
    when 'Delivered' then 'btn success'
    when 'For-Delivery', 'Paid', 'Closed' then ''
    else 'black'
    end
  end
  
  def was_fulfilled
    status == 'Delivered' || status == 'Paid' || status == 'Closed'
  end
  
  def is_not_yet_paid
    due_date.present? && paid.nil?
  end

  def can_be_cancelled(user)
    if user.id == 1 
      true
    else
      status == 'New PO' || status == 'PO Released' || status == 'For-Delivery'
    end
  end
  
  # time computations
  def delivery_time
    (delivered - confirmed.to_date).to_i 
  end
  
  def days_underdue # used in ORDERS#INDEX, RATINGS#FORM
    (due_date - Date.today).to_i
  end

  def days_overdue # used in ORDERS#INDEX, SHOW
    (Date.today - due_date).abs.to_i 
  end
  
  def paid_but_overdue # used in ORDERS#SHOW
    (paid - due_date).to_i 
  end
  
  def self.total_orders
    self.sum(:order_total)
  end
    
  def latest_order
    new_record?
  end
  
  private

  def clean_up_details
    self.deliver_to = self.deliver_to.titleize
    self.contact_person = self.contact_person.titleize
    self.address1 = self.address1.titleize
    self.address2 = self.address2.titleize
    self.instructions = self.instructions.capitalize
  end
  
  
end
