class Fee < ActiveRecord::Base
  belongs_to :entry
  belongs_to :line_item
  belongs_to :buyer, :class_name => "User", :foreign_key => "buyer_id"
  belongs_to :seller, :class_name => "User", :foreign_key => "seller_id"
  belongs_to :buyer_company, :class_name => "Company", :foreign_key => "buyer_company_id"
  belongs_to :seller_company, :class_name => "Company", :foreign_key => "seller_company_id"
  belongs_to :order
  belongs_to :bid
  
  default_scope order('created_at DESC')
  
  scope :for_order, where(fee_type: 'Ordered')
  scope :for_decline, where(fee_type: ['Declined', 'Expired', 'Expired-Rvsd', 'Reversed'])
  
  VAT_RATE = 0.12
  
  def self.find_type(type)
    case type
    when 'sf' then for_order
    when 'bf' then for_decline
    else scoped
    end
  end
  
  def self.by_this_seller(company)
     where(seller_company_id: company.id)
  end
  
  def self.by_this_buyer(user)
    if user.role?(:powerbuyer)
      where(:buyer_company_id => user.company)
    else     
      where(:buyer_id => user)
    end
  end
  
  def self.filter_period(search_query=nil)
    if search_query.present?
     scoped
    else
      where(created_at: Date.today.beginning_of_month..Date.today)
    end
  end
  
  def self.compute(bid, status, order=nil)
    f = Fee.new
    f.buyer_company_id = bid.entry.user.company.id
    f.buyer_id = bid.entry.user_id
    f.seller_company_id = bid.user.company.id
    f.seller_id = bid.user_id
    f.entry_id = bid.entry_id
    f.line_item_id = bid.line_item_id
    f.bid_id = bid.id
    f.bid_total = bid.total
    f.bid_type = bid.bid_type
    f.bid_speed = bid.bid_speed 
    if status == 'Paid' || status == 'Closed' # Market Fees
      f.fee_type = 'Ordered'
      f.order_id = order if order
      # f.created_at = bid.paid if bid.paid
      f.order_paid = f.order.paid.to_date
      ratio = f.seller_company.perf_ratio
      if ratio < 70
        f.fee_rate = 3.5 - f.seller_discount
      elsif ratio < 80         
        f.fee_rate = 3.0 - f.seller_discount
      elsif ratio >= 80       
        f.fee_rate = 2.0 - f.seller_discount
      end
      f.fee = f.bid_total * (f.fee_rate.to_f/100)
      f.perf_ratio = ratio
    else                                      # Decline Fees
     if bid.expired
        # f.created_at = bid.expired
        f.fee_type = 'Expired'
      else
        # f.created_at = bid.declined
        f.fee_type = 'Declined'
      end
      ratio = f.buyer_company.perf_ratio
      if ratio < 10
        f.fee_rate = 0.5 - f.buyer_discount(0.5).to_f
      elsif ratio < 30
        f.fee_rate = 0.375 - f.buyer_discount(0.375).to_f
      elsif ratio < 50
        f.fee_rate = 0.25 - f.buyer_discount(0.25).to_f
      elsif ratio >= 50
        f.fee_rate = 0
      end
      f.fee = f.bid_total * (f.fee_rate.to_f/100)
      f.split_amount = f.fee/2 
      f.perf_ratio = ratio
    end
    f.save
  end
  
  def seller_discount
    if bid.bid_speed < 4.hours
      0.5
    elsif bid.bid_speed <= 8.hours
      0.25
    else
      0
    end 
  end
  
  def buyer_discount(base_rate)
    unless bid.blank?
      if bid.bid_speed < 4.hours
        0
      elsif bid.bid_speed <= 8.hours
        base_rate * 0.25
      elsif bid.bid_speed <= 2.days
        base_rate * 0.50
      elsif bid.bid_speed > 2.days
        base_rate * 1.00
      end 
    end
  end

  def reverse
    update_attribute(:fee_type, fee_type + '-Rvsd') unless self.was_reversed
    f = Fee.new(self.attributes)
    f.bid_type = f.bid_speed = f.perf_ratio = f.fee_rate = nil
    f.bid_total = 0
    f.fee = 0 - self.fee
    f.fee_type = 'Reversed'
    f.created_at = Time.now.to_date
    f.split_amount = 0 - self.split_amount
    f.save!
  end  
  
  def was_reversed
    fee_type == 'Expired-Rvsd'
  end
  
  def reversal?
    fee_type == 'Reversed'
  end
  
  def self.base_fee
    self.sum(:fee)
  end
  
  def self.vat
    self.base_fee * VAT_RATE
  end
  
  def self.total_fee
    self.base_fee + self.vat
  end
  
  def self.supplier_share
    self.sum(:split_amount)
  end
end
