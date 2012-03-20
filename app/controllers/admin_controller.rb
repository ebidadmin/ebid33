class AdminController < ApplicationController
  include ActionView::Helpers::TextHelper
  
  def update_ratios
    for company in Company.all
      if company.primary_role == 2 # buyer
        company.compute_buyer_ratio
      # elsif company.primary_role == 3 # seller
      #   company.compute_seller_ratio
      end
      company.save!
    end
    flash[:success] = "Performance Ratios successfully updated!"
    redirect_to request.env["HTTP_REFERER"]
  end
  
  def expire_entries
    if params[:id]
      @entry = Entry.find(params[:id])
      @entry.expire(1)
      flash[:success] = "Expired #{@entry.id}."
    else
      @entries = Entry.unscoped.for_decision.unexpired.includes(:line_items => :bids).order(:created_at)#.limit(5)
      @entries.each do |entry|
        entry.expire
      end
      flash[:success] = "Expired #{pluralize @entries.count, 'entry'}."
    end
    redirect_to :back  
  end
  
  def tag_payments
    @orders ||= Order.where(status: 'Paid').payment_pending.payment_taggable.includes(:bids => :line_item)#.limit(5)
    @orders.each do |order|
      order.tag_payment #if order.paid_temp.to_datetime <= Order::TAG_AS_PAID # proceed only if tagged by buyer more than 3 days ago
    end
    flash[:success] = "Tagged #{pluralize @orders.count, 'order'}."
    redirect_to :back
  end
  
  def send_payment_reminder
    overdue_orders ||= Order.unscoped.overdue.includes(:company).order(:due_date)
    if overdue_orders.present?
      overdue_orders.group_by(&:company).each do |company, overdue|
        @powerbuyers = company.users.where(:id => Role.find_by_name('powerbuyer').users).opt_in.includes(:profile).collect { |u| "#{u.profile} <#{u.email}>" }
        Notify.delay.overdue_payment(@powerbuyers, company.nickname, overdue)#.deliver
      end
    end
    
    due_now_orders ||= Order.unscoped.due_now.includes(:company).order(:due_date)
    if due_now_orders.present?
      due_now_orders.group_by(&:company).each do |company, due_now|
        @powerbuyers = company.users.where(:id => Role.find_by_name('powerbuyer').users).opt_in.includes(:profile).collect { |u| "#{u.profile} <#{u.email}>" }
        Notify.delay.due_now(@powerbuyers, company.nickname, due_now)#.deliver
      end
    end
    redirect_to :back, :notice => 'Sent payment reminders to Buyers.'
  end
  
  def delivery_reminder
    late_deliveries = Order.unscoped.find_status('for-delivery').where('confirmed <= ?', 3.days.ago).order(:confirmed)
    if late_deliveries
      late_deliveries.group_by(&:seller_company).each do |company, ld|
        @sellers = company.users.includes(:profile).collect { |u| "#{u.profile} <#{u.email}>" }
        Notify.delay.deliver_now(@sellers, company.nickname, ld)#.deliver
      end
    end
    redirect_to :back, :notice => "Sent delivery reminders to Sellers for #{pluralize late_deliveries.count, 'order'}"
  end

  def delfees
    orders = Order.paid.includes(:bids)
    orders.each do |o|
      o.bids.not_cancelled.each { |bid| Fee.compute(bid, 'Paid', o.id) if bid.fees.for_order.blank?  }
    end
    @entries = Entry.expired.where('expired >= ?', Date.today.beginning_of_month).includes(:line_items => :bids)
    @entries.each do |entry|
      entry.line_items.each do |item| 
        if item.bids
          if item.order
            item.update_attribute(:status, item.order.status) unless item.cancelled
            item.bids.not_cancelled.group_by(&:bid_type).each do |t, bids|
              lo = bids[-1]
              others = bids[0..-2]
              if lo.order
                lo.update_attribute(:status, item.order.status)
              else
                lo.update_attributes(status: 'Dropped', declined: nil, expired: nil)
              end
              others.each { |b| b.update_attributes(status: "Lose", declined: nil, expired: nil) } if others.present?
            end
          elsif item.declined_or_expired
            item.update_attribute(:status, "Expired")
            lowest_bid ||= item.bids.not_cancelled.last
            lowest_bid.update_attributes(status: "Declined", declined: Time.now, expired: Time.now)
            Fee.compute(lowest_bid, "Declined") if lowest_bid.fees.for_decline.blank?
          
            item.bids.not_cancelled.group_by(&:bid_type).each do |t, bids|
              lo = bids[-1]
              others = bids[0..-2]
              if lo.id != lowest_bid.id
                lo.update_attributes(status: "Dropped", ordered: nil, order_id: nil, delivered: nil, paid: nil, declined: nil)
              end
              others.each { |b| b.update_attributes(status: "Lose", ordered: nil, order_id: nil, delivered: nil, paid: nil, declined: nil) } if others.present?
            end
          
          end
        else
          item.update_attribute(:status, "No Bids") 
        end
      end
      entry.update_status
    end
    flash[:success] = "Done!"
    redirect_to :back
  end
end
