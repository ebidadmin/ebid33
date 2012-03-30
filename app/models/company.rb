class Company < ActiveRecord::Base
  attr_accessible :name, :nickname, :primary_role, :trial_start, :trial_end, 
  :metering_date, :perf_ratio
  
  belongs_to :role, :class_name => "Role", :foreign_key => "primary_role"
  
  has_many :profiles
  has_many :users, through: :profiles
  has_many :branches, :dependent => :destroy#, through: :profiles
  has_many :friendships, :dependent => :destroy
  has_many :friends, :through => :friendships
  has_many :entries
  has_many :orders
  has_many :seller_companies, through: :orders
  has_many :messages
  has_many :user_companies, through: :messages
  has_many :receiver_companies, through: :messages
  has_many :buyer_companies, through: :fees
  has_many :seller_companies, through: :fees
  has_many :var_items, dependent: :destroy
  has_many :seller_companies, through: :var_items
  
  RATIO_DATE = Time.now.beginning_of_year #'2011-04-16'.to_datetime #
  
  def compute_buyer_ratio
    es ||= entries.where('created_at >= ?', RATIO_DATE)
    line_items ||= LineItem.with_bids.where(entry_id: es)
    if line_items.count > 0
      parts_ordered = line_items.where('order_id IS NOT NULL').count
      self.perf_ratio = (BigDecimal("#{parts_ordered}")/BigDecimal("#{line_items.count}")).to_f * 100
    else
      self.perf_ratio = 0
    end
  end
  
  def compute_seller_ratio
    parts_bided = users.map{|user| user.bids.where('bids.created_at >= ?', RATIO_DATE).collect(&:line_item_id).uniq.count}.sum
    line_items = LineItem.where('line_items.created_at >= ?', RATIO_DATE).count
    self.perf_ratio = (BigDecimal("#{parts_bided}")/BigDecimal("#{line_items}")).to_f * 100
  end
end
