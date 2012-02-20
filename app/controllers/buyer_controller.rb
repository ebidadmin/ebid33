class BuyerController < ApplicationController
  before_filter :initialize_cart, :only => [:show, :edit]
  
  def entries
    @q = Entry.search(params[:q])
    @entries = @q.result.by_this_buyer(current_user, params[:q]).find_status(params[:s]).includes([:user => :profile], :car_brand, :car_model, :bids, :messages).paginate(page: params[:page], per_page: 10)#.order('bid_until DESC')
    @branches = current_user.company.branches.includes(:users => :profile)
  end
  
  def show
    @entry = Entry.find(params[:id], include: [[:line_items => :order]])
    @q = CarPart.search(params[:q])
    
    if current_user.role?(:admin)
      @pvt_messages = @entry.messages.pvt
    else
      @pvt_messages = @entry.messages.pvt.restricted(current_user.company)
    end
    @pub_messages = @entry.messages.pub
  end
  
  def surrender
    @entry = Entry.find(params[:id], include: :line_items)
    render layout: 'layout2'
  end
  
  def surrender_letter
    @entry = Entry.find(params[:id], include: :line_items)
    render layout: 'layout2'
  end
  
  def reactivate
    show
    flash[:notice] = "Choose the items you want to reactivate, then Create PO."
    render 'show'
  end
  
  def orders
    @q = Order.find_status(params[:s]).by_this_buyer(current_user).search(params[:q])
    @all_orders ||= @q.result
    @orders = @all_orders.includes([:entry => [:car_brand, :car_model, :user]], :seller_company, :messages).paginate :page => params[:page], :per_page => 10

    seller_present?
  end
  
  def fees
    @q = Fee.for_decline.by_this_buyer(current_user).filter_period(params[:q]).search(params[:q])
    @all_fees ||= @q.result
    @fees = @all_fees.includes([:entry => [:user, :car_brand, :car_model]], [:line_item => :car_part]).paginate(page: params[:page], per_page: 15)
    
    seller_present?
  end
  
  private
  
  def seller_present?
    if params[:q] && params[:q][:seller_company_id_matches].present?
      @seller_company = Company.find(params[:q][:seller_company_id_matches])
    end
  end
end
