class Entry < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers
  
  attr_accessible :user_id, :company_id, :ref_no, :year_model, :car_brand_id, :car_model_id, :car_variant_id, :plate_no, :serial_no, :motor_no, 
  :date_of_loss, :city_id, :term_id, :line_items_count, :photos_count, :status, :online, :bid_until, :bids_count, :decided, :relisted, :relist_count, 
  :expired, :chargeable_expiry, :oders_count, :photos_attributes
  attr_accessor :region

  before_save :convert_numbers

  belongs_to :user
  belongs_to :company
  belongs_to :car_brand
  belongs_to :car_model
  belongs_to :car_variant
  belongs_to :city
  belongs_to :term

  has_many :photos, dependent: :destroy#, validate: true
  accepts_nested_attributes_for :photos, allow_destroy: true, :reject_if => proc { |a| a['photo'].blank? }
  
  has_many :line_items, dependent: :destroy
  accepts_nested_attributes_for :line_items, allow_destroy: true, reject_if: proc { |obj| obj.blank? }
  has_many :car_parts, through: :line_items
  has_many :bids, dependent: :destroy
  has_many :orders, validate: true
  accepts_nested_attributes_for :orders, allow_destroy: true, reject_if: proc { |obj| obj.blank? }
  has_many :messages, dependent: :destroy
  has_many :fees
  has_many :variances, dependent: :destroy
  has_many :surrenders, dependent: :destroy
  
  default_scope order('created_at DESC')
  scope :active, where('entries.bid_until >= ?', Date.today)
  scope :unexpired, where(:expired => nil)
  scope :expired, where('expired IS NOT NULL')

  scope :online, where(status: ['Online', 'Relisted', 'Additional', 'Re-bidding']).order('bid_until DESC')
  scope :for_decision, where(status: ['For-Decision', 'Ordered-IP', 'Declined-IP'])
  scope :with_orders, where('entries.status LIKE ?', "%Ordered%") 
  scope :declined, where(status: ['Declined-IP', 'Declined-All'])
  scope :for_seller, where{(status.not_like '%New%') & (status.not_like '%Edited%') & (status.not_like '%Removed%')} #where('entries.status NOT LIKE ?', ['New', 'Edited', 'Removed'])
  
  validates_presence_of :year_model, :car_brand, :car_brand_id, :car_model_id, 
  :plate_no, :serial_no, :motor_no, :date_of_loss, :city_id, :term_id
  validates_associated :photos, :orders
  
  delegate :term_name, to: :term
  
  YEAR_MODELS = (30.years.ago.year .. Date.today.year).to_a.reverse
  STATUS_TAGS = %w(New Online Additional Relisted For-Decision Ordered-IP Ordered-All Ordered-Declined Declined-IP Declined-All) 
  # TAGS_FOR_INDEX = %w(new online for-decision ordered declined)
  TAGS_FOR_SIDEBAR = %w(online relisted bid_until decided expired)
  MIN_BIDDING_TIME = 3.hours #5.minutes
  DAYS_TO_EXPIRY = 3.days
  
  def model_name
    "#{year_model} #{car_brand.name if car_brand} #{car_model.name if car_model}".html_safe 
  end
  
  def variant
    car_variant.name.html_safe if car_variant.present?
  end
  
  def self.find_status(status)
    case status
    when 'new' then where(status: ['New', 'Edited'])
    when 'online' then online.active
    when 'for-decision' then for_decision.unexpired.order('decided DESC')
    when 'ordered' then with_orders
    when 'declined' then declined
    when 'all' then for_seller
    else scoped
    end
  end
    
  def self.by_this_buyer(user, search_query=nil)
    # if search_query.present?
    #   scoped
    # else
      if user.role?(:powerbuyer)
        where(company_id: user.company)
      else
        where(user_id: user)
      end
    # end
  end
  
	def add_line_items_from_cart(cart, specs, hash_items=nil)
		cart.cart_items.each do |item|
			li = LineItem.from_cart_item(item, specs.fetch(item.id.to_s)[0].to_s)
			line_items << li 
		end
    cart.cart_items.destroy_all
    if hash_items.present?
      # hash_items.reject! proc { |obj| obj.blank? }
      existing_items = LineItem.unscoped.find(hash_items.map { |k,v| k.to_i })
      existing_items.each do |ei|
        ei.update_attribute(:specs, hash_items.fetch(ei.id.to_s)[0])
      end
    end
	end 

  def update_associated_status(status)
    if status == "Online"
      line_items.update_all(:status => status)
      bids.update_all(:status => 'New') if bids.present?
    elsif status == "For-Decision" # ordinarily handled by entries/reveal, but included here for entries/revert
      update_attributes(:expired => nil, :chargeable_expiry => nil)
      for item in line_items.with_bids.includes(:bids, :order_item)
         item.update_for_decision
      end
    else
      line_items.update_all(:status => status)
      bids.not_cancelled.update_all(:status => status) if bids.present?
    end
	end
	
  def update_status
    items_with_bids = line_items.with_bids.count
	  unless orders.blank?
      if items_with_bids == bids.with_orders.count
        update_attribute(:status, "Ordered-All")
      elsif items_with_bids == bids.with_orders.count + line_items.declined.count
        update_attribute(:status, "Ordered-Declined")
      else
        update_attribute(:status, "Ordered-IP")
      end
	  else
  	  declined_count = line_items.declined.count
      if items_with_bids == declined_count
        update_attribute(:status, "Declined-All")
      else
        update_attribute(:status, "Declined-IP")
      end
	  end
	end
	
	def put_online
	  if self.update_attributes(status: "Online", online: Time.now, bid_until: 1.week.from_now)
      self.update_associated_status("Online")
      self.send_online_mailer
      flash = "Your entry is #{content_tag :strong, 'now online'}. Suppliers have been notifed through email.".html_safe
    end
	end
	
  def relist # also applicable for addtional parts
    if line_items.relistable.present?
      line_items.relistable.update_all(status: 'Relisted', relisted: Time.now)
      self.update_attributes(status: 'Relisted', bid_until: 1.week.from_now, relisted: Time.now, relist_count: self.relist_count += 1, chargeable_expiry: nil, expired: nil)
    end
    if line_items.fresh.present?
      line_items.fresh.update_all(status: 'Additional')
      self.update_attributes(status: 'Additional', bid_until: 1.week.from_now, relisted: Time.now, relist_count: self.relist_count += 1, chargeable_expiry: nil, expired: nil)
    end
    self.send_online_mailer
    flash = "Your entry is #{content_tag :strong, 'now online'}. Thanks!".html_safe
  end
  
  def send_online_mailer
    self.company.friends.includes(:users => :profile).each do |friend|
      if friend.users.opt_in.present?
        sellers = friend.users.opt_in.includes(:profile).collect { |u| "#{u.profile} <#{u.email}>" }
        Notify.delay.online_entry(sellers, self)#.deliver 
      end
    end
  end

  def reveal
    if self.update_attributes(status: "For-Decision", decided: Time.now, expired: nil)
      line_items.includes(:bids, :order).each { |item| item.update_for_decision if item.order.blank? }
      flash = "Bidding is now finished. Bids are revealed below. You can proceed to Create PO.".html_safe
    end
  end
  
	def expire(force=nil)
	  if force
      line_items.each { |item| item.expire unless item.cannot_be_expired }
      if update_attributes(:chargeable_expiry => true, :expired => Time.now)
        update_status #unless orders.exists?
      end
	  else
      deadline = bid_until + DAYS_TO_EXPIRY 
      if Date.today >= deadline && expired.blank?
        line_items.each { |item| item.expire unless item.cannot_be_expired }
        if update_attributes(chargeable_expiry: true, expired: Time.now)
          update_status #unless orders.exists?
        end
      end
	  end
	end
	
	def rebid
    if self.update_attributes(status: 'Re-bidding', bid_until: 3.days.from_now, relisted: Time.now, relist_count: self.relist_count += 1, chargeable_expiry: nil, expired: nil)
	    line_items.update_all(status: 'Re-bidding', relisted: Time.now)
      bids.not_cancelled.update_all(status: 'Re-bidding') if bids.present?
	  end
	end
	
	def newly_created? 
    status == 'New' || status == 'Edited'
  end
  
  def can_be_edited
    decided.nil? || expired.nil? || created_at > 3.weeks.ago 
  end
  
  def can_online
    line_items.present? && photos.present? && bid_until.blank? 
  end
  
	def is_online
	  status == 'Online' || status == 'Additional' || status == 'Relisted' || status == 'Re-bidding' 
	end
	
	def can_reveal
    if relisted.present?
      ready_for_reveal = Time.now > relisted + MIN_BIDDING_TIME
    elsif online.present?
      ready_for_reveal = Time.now > online + MIN_BIDDING_TIME
    end
    ready_for_reveal && (bids.present? && bids.online.present?)
	end
	
	def can_relist
    allowed = case status
    when 'New', 'Edited', 'Online', 'Additional', 'Relisted' then false
    else true
    end
    allowed && line_items.collect(&:status).include?('No Bids')
	end
	
	def has_additionals
	  line_items.fresh.present? && bid_until
	end

  def can_be_ordered
    # status_ok = status == "For-Decision" || status == "Ordered-IP" || status == "Declined-IP"
    # status_ok && (line_items.present? && line_items.collect(&:status).uniq.include?("For-Decision"))
    line_items.present? && line_items.collect(&:status).uniq.include?("For-Decision")
  end
  
  def can_reactivate
    # expired && updated_at > 1.month.ago && line_items.collect(&:status).uniq.include?("Expired")
   updated_at > 1.month.ago && line_items.collect(&:status).uniq.include?("Expired")
  end
  
  def has_order
    orders_count > 0
  end
  
  def stock_warning?
    online <= 3.days.ago
  end
  
  def unique_bidders
    bids.collect(&:user_id).uniq.count
  end
  
  def items_bidded
    bids.collect(&:line_item_id).uniq.count
  end
  
  def show_status
    if expired.nil?
      "#{status}"
    else
      "#{status}<br> (Expired)".html_safe
    end
  end
  
  def status_date
    case status
    when 'New' then created_at
    when 'Online' then online
    when 'Additional', 'Relisted', 'Re-bidding' then relisted
    # when 'For-Decision' then decided
    else updated_at
    end
  end
  
	def status_color
    case status
    when 'Online', 'Additional', 'Relisted' then 'label-info'
    when 'For-Decision' then 'label-highlight'
    when 'Ordered-Declined', 'Ordered-IP', 'Ordered-All' then 'label-success'
    when 'Declined-IP', 'Declined-All', 'Re-bidding' then 'label-warning'
    else nil
    end
  end
  
	def get_date_for_sidebar(tag)
	  self.send(tag.downcase)
	end
		
	private
	
	def convert_numbers
	  self.ref_no.upcase!
	  self.plate_no.upcase!
	  self.motor_no.upcase!
	  self.serial_no.upcase!
	end
	
end
