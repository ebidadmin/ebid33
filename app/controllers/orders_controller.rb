class OrdersController < ApplicationController
  include ActionView::Helpers::TagHelper
  has_scope :recent
  has_scope :delivered
  has_scope :paid
  
  
  def index
    @orders = apply_scopes(Order).includes(:entry => [:car_brand, :car_model, :user]).paginate(page: params[:page], per_page: 10)
  end

  def show
    @order = Order.find(params[:id])
    @entry = @order.entry
    render layout: 'layout2'
  end

  def new
    @order = Order.new
  end

  def create
    @orders = Array.new
    @entry = Entry.find(params[:entry_id])
    winning_bids = params[:bids]
    @bids ||= Bid.find(winning_bids.collect { |k,v| k })

    # Create a unique PO per seller
    @bids.group_by(&:user).each do |bidder, bids|
      @order = current_user.orders.build(params[:order])
      @order.populate(current_user, request.remote_ip, bidder.id, bids)
      if @entry.orders << @order
        bids.each { |bid| bid.process_order(@order, winning_bids.fetch(bid.id.to_s)[0].to_i) }
      end
      @orders << @order
    end 

    if @orders.all?(&:valid?) 
      @entry.update_status unless @entry.is_online
      # @orders.each { |order| OrderMailer.delay.order_alert(order) }
      unless @orders.count < 2
        flash[:success] = "Your POs have been released and will be processed right away.<br>
          Your suppliers are #{content_tag :strong, @orders.collect{ |o| o.seller.company.name }.to_sentence}. Thanks!".html_safe
      else
        flash[:success] = ("Your PO has been released and will be processed right away.<br> 
          Your supplier is #{content_tag :strong, @order.seller.company.name}. Thanks!").html_safe
      end
    else
      flash[:error] = "Failed to generate PO. #{content_tag :strong, 'Please make sure you input the required information'}.".html_safe
    end
    redirect_to @entry 
  end

  def edit
    @order = Order.find(params[:id], include: [:bids => [:line_item => :car_part]])
    @bids ||= @order.bids.includes(:line_item => :car_part)
    @bidders = @bids.collect(&:user_id).uniq
    @entry = @order.entry
    render layout: 'layout2'
  end

  def update
    @order = Order.find(params[:id])
    winning_bids = params[:bids]
    @bids ||= Bid.find(winning_bids.collect { |k,v| k })

    if @order.update_attributes(params[:order])
      @bids.each do |bid|
        qty = winning_bids.fetch(bid.id.to_s)[0].to_i
        bid.update_attributes(quantity: qty, total: bid.amount * qty) if bid.quantity != qty
      end
      @order.update_attribute(:order_total, @bids.collect(&:total).sum)
      redirect_to @order, :notice  => "Successfully updated order."
    else
      flash[:warning] = "Failed to update PO. #{content_tag :strong, 'Please make sure you input the required information'}."
      redirect_to :back #render :action => 'edit'
    end
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to orders_url, :notice => "Successfully destroyed order."
  end
  
end
