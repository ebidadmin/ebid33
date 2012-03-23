class Variance < ActiveRecord::Base
  attr_accessible :user_id, :company_id, :seller_company_id, :entry_id, :line_item_id, :bid_id, 
  :amount, :qty, :total, :var_type, :bid_type, :var_amt, :var_total, :discount, :var_base, 
  :variance, :var_company
  
  belongs_to :user
  belongs_to :company
  belongs_to :seller_company, class_name: "Company", foreign_key: "seller_company_id"
  belongs_to :entry
  belongs_to :line_item
  belongs_to :bid
  
  validates_presence_of :var_base, :var_company
  validates_numericality_of :var_base
  validates_numericality_of :qty
  
  DISCOUNTS = %w(5 10 15 20 25 30)
  
  def self.populate(user, var_company, discount, line_item, vars)
    v = user.variances.build
    v.company_id =  user.company.id 
    v.line_item_id =  line_item 
    v.qty =  vars['qty']
    v.var_base =  vars['amt']
    v.discount =  discount
    v.var_amt =  v.var_base.to_f * (1 - (discount.to_f/100))
    v.var_total =  v.qty * v.var_amt
    v.var_type =  vars['type']
    v.var_company = var_company

    comparative_bid = Bid.where(line_item_id: line_item, bid_type: v.var_type).last
    if comparative_bid.present?
      v.bid_id = comparative_bid.id
      v.amount = comparative_bid.amount
      if v.qty == comparative_bid.quantity
        v.total = comparative_bid.total
      else
        v.total = v.qty * comparative_bid.amount
      end
      v.bid_type = comparative_bid.bid_type
      v.variance = v.var_total - v.total
    end
    v
  end
  
end
