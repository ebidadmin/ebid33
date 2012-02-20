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
  
  validates_presence_of :deliver_to#, :address1, :phone

  TAGS_FOR_INDEX = %w(New For-Delivery Delivered Overdue Paid Closed Cancelled)
  
  # default_scope includes(:user, :seller, :bids => [:line_item => :car_part]).order('created_at DESC')
  default_scope order('orders.created_at DESC')

  scope :recent, where(status: ['PO Released', 'New PO', 'For-Delivery'])
  scope :delivered, where(status: 'Delivered')
  scope :payment_valid, where('orders.paid IS NOT NULL')
  scope :payment_pending, where('orders.paid IS NULL')
  scope :paid, where(status: 'Paid').payment_valid
  
  scope :cancelled, where('orders.status LIKE ?', "%Cancelled%")
  scope :not_cancelled, where('orders.status NOT LIKE ?', "%Cancelled%") # used in Orders#Show
  
  scope :overdue, delivered.where('orders.due_date < ?', Date.today)
  
  def self.find_status(status)
   if status == 'new'
      unscoped.where(status: ['New PO', 'PO Released']).order(:created_at)
    elsif status == 'for-delivery'
      unscoped.where(status: 'For-Delivery').order(:confirmed)
    elsif status == 'delivered'
      unscoped.delivered.where('orders.due_date >= ?', Date.today).order(:delivered)
    elsif status == 'overdue'
      unscoped.overdue.order(:delivered)
    elsif status == 'cancelled'
      cancelled
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
  
  def populate(user, ip, bidder, bids)
    self.company_id = user.company.id
    self.buyer_ip = ip
    self.seller_id = bidder.id
    self.seller_company_id = bidder.company.id
    self.order_total = bids.collect(&:total).sum 
    self.items_count = self.items_count + bids.count
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
	    self.update_attributes(status: 'Delivered', delivered: Date.today, due_date: Date.today + entry.term.name.days)
	    flash = "Updated the status of the order to <strong>Delivered</strong>.<br>
      Please send your invoice to buyer asap so we can help you <strong>track the payment</strong>.".html_safe
    when 'Paid!'
      self.update_attributes(status: 'Paid', paid_temp: Date.today)
      flash = "Updated the status of the order to <strong>Paid</strong>.<br>
      We will notify the seller to confirm your payment.".html_safe
    when 'Paid', 'Confirm Payment'
      self.update_attributes(status: 'Paid', paid: Date.today)
      flash = "Updated the status of the order to <strong>Paid</strong>.<br>
      Please rate your buyer to close the order.".html_safe
	  end
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

  def can_be_cancelled(user, action)
    if user.id == 1 || action == 'cancel'
      true
    else
      status == 'New PO' ||status == 'PO Released' || status == 'For-Delivery'
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
    (Date.today - due_date).abs.to_i - 1
  end
  
  def paid_but_overdue # used in ORDERS#SHOW
    (paid - due_date).to_i 
  end
  
  def self.total_orders
    self.sum(:order_total)
  end
    
  private

  def clean_up_details
    self.contact_person = self.contact_person.titleize
    self.address1 = self.address1.titleize
    self.address2 = self.address2.titleize
    self.instructions = self.instructions.capitalize
  end
  
  
end
