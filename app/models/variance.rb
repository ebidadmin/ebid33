class Variance < ActiveRecord::Base
  attr_accessible :user_id, :company_id, :entry_id, :var_company_id, :var_items_attributes
  attr_accessor :discount
  
  belongs_to :user
  belongs_to :company
  belongs_to :entry
  belongs_to :var_company
  has_many :var_items, dependent: :destroy
  accepts_nested_attributes_for :var_items, allow_destroy: true, reject_if: lambda { |vi| ( vi[:var_base].blank?) }
  
  # validates_presence_of :var_company
  
  DISCOUNTS = %w(5 10 15 20 25 30 35 40)
  TYPES = %w(original replacement surplus)
  
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
  
  def colonize(user, discount)
    self.company_id = user.profile.company_id
    self.var_items.each { |vi| vi.populate(discount) }
  end
  
end
