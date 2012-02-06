class Message < ActiveRecord::Base
  attr_accessible :user_id, :user_type, :alias, :user_company_id, :reciever_id, :reciever_company_id, 
  :entry_id, :order_id, :message, :open_tag, :ancestry, :parent_id
  
  has_ancestry
  
  before_save :strip_blanks
  
  belongs_to :entry
  belongs_to :order
  belongs_to :user
  belongs_to :reciever, :class_name => "User", :foreign_key => "reciever_id"
  belongs_to :user_company, :class_name => "Company", :foreign_key => "user_company_id"
  belongs_to :reciever_company, :class_name => "Company", :foreign_key => "reciever_company_id"

  # default_scope includes([:user => :company], [:reciever => :company]).order('created_at DESC')
  default_scope includes(:user)
  scope :pub, where(open_tag: true)
  scope :pvt, where(open_tag: false)
  
  validates_presence_of :message

  RANDOM_NUMBERS = (1..20)
      
  def self.restricted(company)
    where('user_company_id = ? OR reciever_company_id = ?', company, company)
  end

  def generate_random_alias(user)
    
  end
  
  def create_message(current_user, msg_for, open_msg_tag = nil, entry = nil, order = nil)
    self.user_company_id = current_user.company.id
    self.user_type = current_user.roles.first.name
    self.entry_id = entry.id unless entry.blank?
    self.order_id = order.id unless order.blank?
    if msg_for == 'admin'
      self.reciever_id = 1
      self.reciever_company_id = 1
      self.open_tag = open_msg_tag unless open_msg_tag.blank?
    elsif msg_for == 'buyer'
      self.reciever_id = entry.user_id
      self.reciever_company_id = entry.company_id
      self.open_tag = open_msg_tag unless open_msg_tag.blank?
    elsif msg_for == 'seller'
      self.reciever_id = order.seller_id
      self.reciever_company_id = order.seller.company.id
      self.open_tag = open_msg_tag unless open_msg_tag.blank?
    elsif msg_for == 'public'
      self.open_tag = true
    end
  end
  
  
  def self.for_cancelled_order(current_user, msg_sender, order, cancelled_bids, reason)
    msg = current_user.messages.build
    if msg_sender == 'admin'
      msg.user_company_id = order.company_id
    else
      msg.user_company_id = current_user.company.id
    end
    msg.user_type = msg_sender
    msg.entry_id = order.entry_id 
    
    if msg_sender == 'seller' 
      msg.reciever_id = order.user_id
      msg.reciever_company_id = order.company_id
    elsif msg_sender == 'buyer' || msg_sender == 'admin'
      msg.reciever_id = order.seller_id
      msg.reciever_company_id = order.seller.company.id
    end
    
    if order.bids.all?(&:cancelled?)
      msg.message = "ENTIRE ORDER cancelled *** #{cancelled_bids.collect { |b| b.line_item.part_name}.to_sentence} *** REASON: #{reason.strip.capitalize}"
      order.update_attributes(status: "Cancelled", cancelled: Date.today, order_total: order.bids.collect(&:total).sum)
      # "ENTIRE ORDER cancelled."
    else
      msg.message = "PARTIAL ORDER cancelled *** #{cancelled_bids.collect { |b| b.line_item.part_name}.to_sentence} *** REASON: #{reason.strip.capitalize}"
      order.update_attribute(:order_total, order.order_total - cancelled_bids.collect(&:total).sum) unless order.order_total == 0
      # "PARTIAL ORDER cancelled."
    end
    order.messages << msg
  end
  
  def can_be_edited(current_user)
    self.user == current_user || current_user.role?(:admin)
  end
  
  private
  
  def strip_blanks
    self.message.strip.capitalize
  end
  
end
