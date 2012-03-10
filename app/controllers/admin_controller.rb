class AdminController < ApplicationController
  include ActionView::Helpers::TextHelper
  
  def update_ratios
    for company in Company.all
      if company.primary_role == 2 # buyer
        company.compute_buyer_ratio
      elsif company.primary_role == 3 # seller
        company.compute_seller_ratio
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
    @orders ||= Order.where(status: 'Paid').payment_pending.payment_taggable.includes(:bids => :line_item).limit(5)
    @orders.each do |order|
      order.tag_payment #if order.paid_temp.to_datetime <= Order::TAG_AS_PAID # proceed only if tagged by buyer more than 3 days ago
    end
    flash[:success] = "Tagged #{pluralize @orders.count, 'orders'}."
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
end
