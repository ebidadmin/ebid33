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

  validates_presence_of :year_model, :car_brand, :car_brand_id, :car_model_id, 
  :plate_no, :serial_no, :motor_no, :date_of_loss, :city_id, :term_id
  
  YEAR_MODELS = (30.years.ago.year .. Date.today.year).to_a.reverse
  
  def model_name
    "#{year_model} #{car_brand.name} #{car_model.name if car_model}".html_safe 
  end
  
  def variant
    car_variant.name.html_safe
  end
  
end
