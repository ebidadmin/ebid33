class Notify < ActionMailer::Base
  default from: "E-Bid Admin <admin@ebid.com.ph>"
  helper :application
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
    
  def online_entry(sellers, entry)
    @entry = entry
    mail(
      to: sellers, 
      subject: "#{entry.status.upcase}: #{entry.model_name}", 
      )
  end
  
  def bids_submitted(bids, entry, bidder)
    @bids = bids
    @entry = entry
    mail(
      to: "#{entry.user.shortname} <#{entry.user.email}>", 
      subject: "Bids Submitted #{entry.model_name}", 
      )
  end
  
  def new_order(order)
    @order = order
    mail(
      to: "#{order.seller.profile} <#{order.seller.email}>", 
      subject: "New PO: #{ph_currency order.order_total}", 
      bcc: ["Chris Marquez <cymarquez@ebid.com.ph>", "Efren Magtibay <epmagtibay@ebid.com.ph>"]
      )
  end
  
  def payment_tagged(order, entry)
    @order = order
    @entry = entry
    mail(
      to: "#{order.seller.profile} <#{order.seller.email}>", 
      subject: "PO Tagged as 'Paid'", 
      bcc: ["Chris Marquez <cymarquez@ebid.com.ph>", "Efren Magtibay <epmagtibay@ebid.com.ph>"]
      )
  end
  
  def overdue_payment(powerbuyers, company, orders)
    @orders = orders
    @company_name = company
    mail(
      to: powerbuyers, 
      subject: "OVERDUE PAYMENT Reminder", 
      bcc: ["Chris Marquez <cymarquez@ebid.com.ph>", "Efren Magtibay <epmagtibay@ebid.com.ph>"]
      )
  end

  def due_now(powerbuyers, company, orders)
    @orders = orders
    @company_name = company
    mail(
      to: powerbuyers, 
      subject: "DUE NOW Reminder", 
      bcc: ["Chris Marquez <cymarquez@ebid.com.ph>", "Efren Magtibay <epmagtibay@ebid.com.ph>"]
      )
  end
  
  def deliver_now(sellers, company, orders)
    @orders = orders
    @company_name = company
    mail(
      to: sellers, 
      subject: "LATE DELIVERY Reminder", 
      bcc: ["Chris Marquez <cymarquez@ebid.com.ph>", "Efren Magtibay <epmagtibay@ebid.com.ph>"]
      )
  end
  
  def new_message(entry, message)
    @entry = entry
    @message = message
    unless message.receiver.blank?
      mail(
        to: "#{message.receiver.profile} <#{message.receiver.email}>", 
        subject: "You have a PM for #{entry.model_name}", 
        bcc: ["Chris Marquez <cymarquez@ebid.com.ph>"]
        )
    else
      mail(
        to: "Chris Marquez <cymarquez@ebid.com.ph>", 
        subject: "Public Message for #{entry.model_name}" 
        )
    end
  end
  
  def cancelled_order(order, message)
    @order = order
    @message = message
    mail(
      to: ["#{order.user.profile} <#{order.user.email}>", "#{order.seller.profile} <#{order.seller.email}>"],
      subject: "Order CANCELLED",
      cc: ["Chris Marquez <cymarquez@ebid.com.ph>", "Efren Magtibay <epmagtibay@ebid.com.ph>"]
      )
  end
end
