class OrdersController < ApplicationController
  include ActionView::Helpers::TagHelper
  # load_and_authorize_resource
  before_filter :check_admin_role, only: [:index, :destroy]
  before_filter :check_seller_role, only: [:accept]
  before_filter :check_buyer_role, only: [:create, :edit, :update]
  
  def index
    @q = Order.search(params[:q])
    @all_orders ||= @q.result.find_status(params[:s])
    @orders = @all_orders.includes([:entry => [:car_brand, :car_model, :user]], :seller_company, :messages).paginate :page => params[:page], :per_page => 10

  end

  def show
    store_location
    @order = Order.find(params[:id], include: [:bids => [:line_item => :car_part]])
    if can?(:access, :all) || @order.company_id == current_user.company.id || @order.seller_company_id == current_user.company.id
      @entry = @order.entry
      if can? :access, :all
        @pvt_messages = @order.messages.pvt
      else              
        @pvt_messages = @order.messages.pvt.restricted(current_user.company)
      end
      render layout: 'layout2'
    else
      flash[:error] = "Sorry. You are not authorized to view that page."
      redirect_back_or_default(edit_user_path(current_user))
    end
  end

  def print
    @order = Order.find(params[:id])
    @entry = @order.entry
    
    if current_user.role?(:admin)
      @pvt_messages = @order.messages.pvt
    else              
      @pvt_messages = @order.messages.pvt.restricted(current_user.company)
    end
    render layout: 'print'
  end
  
  def new
    @order = Order.new
  end

  def create
    @orders = Array.new
    @entry = Entry.find(params[:id])
    winning_bids = params[:bids]
    @bids ||= Bid.find(winning_bids.collect { |k,v| k })

    # Create a unique PO per seller
    @bids.group_by(&:user).each do |bidder, bids|
      @order = @entry.orders.build(params[:entry][:order])
      @order.populate(current_user, request.remote_ip, bidder, bids, winning_bids) 
      # if current_user.orders << @order
      #   bids.each { |bid| bid.process_order(@order, winning_bids.fetch(bid.id.to_s)[0].to_i) }
      # end
      @orders << @order
    end 

    if @orders.all?(&:valid?) 
      @entry.update_attribute(:ref_no, params[:entry][:ref_no])
      @entry.update_status unless @entry.is_online
      @orders.each { |o| Notify.delay.new_order(o) }
      unless @orders.count < 2
        flash[:success] = "Your POs have been released and will be processed right away.<br>
          Your suppliers are #{content_tag :strong, @orders.collect{ |o| o.seller.company.name }.to_sentence}. Thanks!".html_safe
      else
        flash[:success] = ("Your PO has been released and will be processed right away.<br> 
          Your supplier is #{content_tag :strong, @order.seller.company.name}. Thanks!").html_safe
      end
    else
      # TODO
      flash[:error] = "Failed to generate PO. #{content_tag :strong, 'Please make sure you input the required information'}.".html_safe
    end
    redirect_to buyer_show_path(@entry) #session['referer'], session['referer'] = nil
  end

  def edit
    @order = Order.find(params[:id], include: [:bids => [:line_item => :car_part]])
    @bids ||= @order.bids.includes(:line_item => :car_part)
    @bidders = @bids.collect(&:user_id).uniq
    @entry = @order.entry
    render layout: 'layout2'
  end

  def update
    # raise params.to_yaml
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
  
  def accept
    @order = Order.find(params[:id])
    @entry = @order.entry
    
    if @order.update_attributes(status: "For-Delivery", confirmed: Time.now, seller_confirmation: true)
      @order.update_associated_status("For-Delivery")
      flash[:notice] = ("PO has been confirmed! You buyer is #{content_tag :strong, @entry.user.nickname}.<br> Please deliver ASAP. Thanks!").html_safe
    else
      flash[:error] = "Something went wrong with your request ... please try again later."
    end
    redirect_to :back
  end
  
  def change_status # For tagging of Orders
    @order = Order.find(params[:id])
    flash[:success] = @order.change_status(params[:cs])
    @order.update_associated_status(params[:cs])
    redirect_to @order#:back
  end

  def cancel
      @order = Order.find(params[:id])
    if params[:bid_ids]
      @entry = @order.entry
      @bids = Bid.find(params[:bid_ids])
      @message = current_user.messages.build
      @msg_sender = current_user.roles.first.name
      flash[:info] = "Please indicate your reason for cancelling the order."
      render layout: 'layout2'
    else
      flash[:warning] = "Please select an item you want to cancel. Use the checkboxes."
      redirect_to @order
    end
  end
  
  def confirm_cancel
    @order = Order.find(params[:id])
    @bids = Bid.find(params[:bid_ids])
    if params[:order][:message].present?
      @bids.each { |bid| bid.process_cancellation }
      @message = Message.for_cancelled_order(current_user, params[:msg_sender], @order, @bids, params[:order][:message].capitalize)
      flash[:error] = "Order cancelled. Sayang ..."
      redirect_to @order
    else
      flash[:error] = "Please indicate your reason for cancelling the order."
      redirect_to :back 
    end
  end
  
  
  private
  
  def tag_as_paid
    @order.update_attribute(:paid, Date.today)
    flash[:notice] = ("Successfully updated the status of the order to <strong>Paid</strong>.<br>
    Please rate your buyer to close the order.").html_safe
  end
  
end
