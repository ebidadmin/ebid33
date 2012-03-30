class VarItem < ActiveRecord::Base
  attr_accessible :variance_id, :seller_company_id, :line_item_id, :bid_id, 
  :amount, :qty, :total, :var_type, :bid_type, :var_amt, :var_total, :discount, :var_base, 
  :variance

  belongs_to :variance
  belongs_to :seller_company, class_name: "Company", foreign_key: "seller_company_id"
  belongs_to :line_item
  belongs_to :bid
  
  # validates_presence_of :var_base
  # validates_numericality_of :var_base
  # validates_numericality_of :qty
  # 
  def populate(discount)
    self.discount = discount
    self.var_amt =  self.var_base.to_f * (1 - (discount.to_f/100))
    self.var_total =  self.qty * self.var_amt
    comparative_bid = Bid.where(line_item_id: self.line_item_id, bid_type: self.var_type).last
    if comparative_bid.present?
      self.bid_id = comparative_bid.id
      self.amount = comparative_bid.amount
      if self.qty == comparative_bid.quantity
        self.total = comparative_bid.total
      else
        self.total = self.qty * comparative_bid.amount
      end
      self.bid_type = comparative_bid.bid_type
      self.seller_company_id = comparative_bid.user.company.id
      self.var_net = self.var_total - self.total
    end
  end
end
