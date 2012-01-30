class Entry < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers
  
  attr_accessible :user_id, :company_id, :ref_no, :year_model, :car_brand_id, :car_model_id, :car_variant_id, :plate_no, :serial_no, :motor_no, 
  :date_of_loss, :city_id, :term_id, :line_items_count, :photos_count, :status, :online, :bid_until, :bids_count, :decided, :relisted, :relist_count, 
  :expired, :chargeable_expiry, :oders_count, :photos_attributes
  attr_accessor :region

  belongs_to :user
  belongs_to :company
  belongs_to :car_brand
  belongs_to :car_model
  belongs_to :car_variant
  belongs_to :city
  belongs_to :term

  has_many :photos, dependent: :destroy, validate: true
  accepts_nested_attributes_for :photos, :allow_destroy => true, :reject_if => proc { |a| a['photo'].blank? }
  
  has_many :line_items, dependent: :destroy
  has_many :car_parts, through: :line_items
  has_many :bids, dependent: :destroy
  has_many :orders
  has_many :messages, dependent: :destroy
  has_many :fees
  
  scope :declined, where('entries.status LIKE ?', "%Declined%")
  
  validates_presence_of :year_model, :car_brand, :car_brand_id, :car_model_id, 
  :plate_no, :serial_no, :motor_no, :date_of_loss, :city_id, :term_id
  
  delegate :term_name, to: :term
  
  YEAR_MODELS = (30.years.ago.year .. Date.today.year).to_a.reverse
  STATUS_TAGS = %w(New Online Additional Relisted For-Decision Ordered-IP Ordered-All Ordered-Declined Declined-IP Declined-All) 
  TAGS_FOR_INDEX = %w(New Online Decision Closed)
  TAGS_FOR_SIDEBAR = %w(online relisted bid_until decided expired)
  MIN_BIDDING_TIME = 150.minutes
  
  def model_name
    "#{year_model} #{car_brand.name if car_brand} #{car_model.name if car_model}".html_safe 
  end
  
  def variant
    car_variant.name.html_safe if car_variant.present?
  end
  
  def self.find_status(status)
    finder = case status
    when 'Online', 'Additional', 'Relisted' then ['Online', 'Additional', 'Relisted']
    when 'Decision' then ['For-Decision', 'Ordered-IP', 'Declined-IP']
    when 'Closed' then ['Ordered-Declined', 'Declined-All', 'Ordered-All']
    else status
    end
    status.present? ? where(status: [finder]) : scoped
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
      bids.update_all(:status => status) if bids.present?
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
	
  # def send_online_notification
  #     for friend in @entry.user.company.friends
  #       unless friend.users.nil?
  #         for seller in friend.users
  #           EntryMailer.delay.online_entry_alert(seller, @entry) if seller.opt_in == true
  #         end
  #       end
  #     end
  # end
	
	def newly_created? 
    status == 'New' || status == 'Edited'
  end
  
  def can_online
    line_items.present? && photos.present? && bid_until.blank?
  end
  
	def is_online
	  status == 'Online' || status == 'Additional' || status == 'Relisted'  
	end
	
	def can_reveal
    # ready_for_reveal = case status
    # when 'Relisted', 'Additional' then Time.now > relisted + MIN_BIDDING_TIME
    # when 'Online' then Time.now > online + MIN_BIDDING_TIME
    # end
    if relisted.present?
      ready_for_reveal = Time.now > relisted + MIN_BIDDING_TIME
    elsif online.present?
      ready_for_reveal = Time.now > online + MIN_BIDDING_TIME
    end
    ready_for_reveal && (bids.present? && bids.online.present?)
	end

  def can_be_ordered
    status_ok = status == "For-Decision" || status == "Ordered-IP" || status == "Declined-IP"
    status_ok && (line_items.present? && line_items.collect(&:status).uniq.include?("For-Decision"))
  end
  
  def unique_bidders
    bids.collect(&:user_id).uniq.count
  end
  
  def items_bidded
    bids.collect(&:line_item_id).uniq.count
  end
  
  def status_date
    case status
    when 'New' then created_at
    when 'Online' then online
    when 'Additional', 'Relisted' then relisted
    # when 'For-Decision' then decided
    else updated_at
    end
  end
  
	def status_color
    case status
    when 'Online', 'Additional', 'Relisted' then 'cool'
    when 'For-Decision' then 'highlight'
    when 'Ordered-Declined', 'Ordered-IP', 'Ordered-All' then 'success'
    when 'Declined-IP', 'Declined-All' then 'warning'
    else nil
    end
  end
  
	def get_date_for_sidebar(tag)
	  self.send(tag.downcase)
	end
end
