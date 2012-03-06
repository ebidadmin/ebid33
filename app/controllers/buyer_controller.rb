class BuyerController < ApplicationController
  before_filter :initialize_cart, only: [:show, :edit]
  before_filter :search_by_origin, only: [:entries, :orders]
  before_filter :search_by_branch, only: [:entries, :orders]
  
  def entries
    @q = Entry.by_this_buyer(current_user, params[:q]).find_status(params[:s]).search(params[:q])
    @entries = @q.result.includes([:user => :profile], :car_brand, :car_model, :bids, :messages, :orders).paginate(page: params[:page], per_page: 10)#.order('bid_until DESC')
  end
  
  def show
    @entry = Entry.find(params[:id], include: :line_items)
    if @entry.line_items.present?
      @pvt_messages = @entry.messages.pvt.restricted(current_user.company)
      @pub_messages = @entry.messages.pub
    else
      redirect_to add_line_items_path(id: @entry)
    end
  end
  
  def print_entry
    show
    render :layout => 'print'
  end
  
  def reactivate
    show
    flash[:notice] = "Choose the items you want to reactivate, then Create PO."
    render 'show'
  end
  
  def orders
    @q = Order.search(params[:q])
    @all_orders ||= @q.result.find_status(params[:s]).by_this_buyer(current_user)
    @orders = @all_orders.includes([:entry => [:car_brand, :car_model, :user]], :seller_company, :messages).paginate :page => params[:page], :per_page => 10

    @seller_company = Company.find(params[:q][:seller_company_id_matches]).nickname if params[:q] && params[:q][:seller_company_id_matches].present?
  end
  
  def fees
    @q = Fee.for_decline.by_this_buyer(current_user).filter_period(params[:q]).search(params[:q])
    @all_fees ||= @q.result
    @fees = @all_fees.includes([:entry => [:user, :car_brand, :car_model]], [:line_item => :car_part]).paginate(page: params[:page], per_page: 15)
    
    buyer_present?
    seller_present?
  end
  
  def surrender
    @entry = Entry.find(params[:id], include: :line_items)
    render layout: 'layout2'
  end
  
  def surrender_letter
    raise params.to_yaml
    @entry = Entry.find(params[:id], include: :line_items)
    render layout: 'print'
  end
  
  private
  
  def search_by_branch
    @branches = current_user.company.branches.includes(:users => :profile) if can? :search, :users
  end
  
end
