class Entry < ActiveRecord::Base
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
  
  validates_presence_of :year_model, :car_brand, :car_brand_id, :car_model_id, 
  :plate_no, :serial_no, :motor_no, :date_of_loss, :city_id, :term_id
  
  YEAR_MODELS = (30.years.ago.year .. Date.today.year).to_a.reverse
  
  def model_name
    "#{year_model} #{car_brand.name} #{car_model.name if car_model}".html_safe 
  end
  
  def variant
    car_variant.name.html_safe if car_variant.present?
  end
  
	def is_online
	  status == 'Online' || status == 'Additional' || status == 'Relisted'  
	end

  def can_be_ordered
    status == "For-Decision" || status == "Ordered-IP" || status == "Declined-IP" 
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
	
	def status_color
    case status
    when 'Online' then 'notice'
    when 'Additional' then 'notice'
    when 'Relisted' then 'notice'
    when 'For-Decision' then 'highlight'
    when 'Ordered' then 'success'
    when 'Ordered-Declined' then 'success'
    when 'Ordered-IP' then 'success'
    when 'Ordered-All' then 'success'
    when 'Closed' then 'success'
    when 'Expired' then 'warning'
    when 'Declined' then 'warning'
    when 'Declined-IP' then 'warning'
    when 'Declined-All' then 'warning'
    else nil
    end
  end
  
	
end
