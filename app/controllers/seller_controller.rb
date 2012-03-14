class SellerController < ApplicationController
  before_filter :check_seller_role
  before_filter :search_by_origin, only: [:bids, :fees]
  
  def entries
    @q ||= Entry.find_status(params[:s]).search(params[:q])
    @entries = @q.result.includes(:user, :photos, :car_brand, :car_model, :line_items, :bids, :city, :term, :messages).page(params[:page]).per_page(10)
    # todo: friends
  end
    
  def worksheet
    if params[:entries] 
      @entries = Entry.where(:id => params[:entries])
    else
      @entries = Entry.online.active
      # @entries = Entry.online.active.user_company_friendships_friend_id_eq(current_user.company).inclusions
    end
    @company = current_user.company
    render layout: 'print'
  end
  
  def bids
    @q = Bid.unscoped.search(params[:q])
    @bids = @q.result.where(:user_id => current_user.company.users).includes([:entry => [:user, :car_brand, :car_model]], [:line_item => :car_part], :user).order('created_at DESC').page(params[:page]).per_page(15)
  end
  
  def show
    @entry = Entry.find(params[:id], include: [:line_items => [:car_part, :bids]])

    @pvt_messages = @entry.messages.pvt.restricted(current_user.company)
    @pub_messages = @entry.messages.pub
  end
  
  def orders
    @q = Order.search(params[:q])
    @all_orders ||= @q.result.find_status(params[:s]).by_this_seller(current_user.company)
    @orders = @all_orders.includes([:entry => [:car_brand, :car_model, :user]], :company, :messages).page(params[:page]).per_page(10)
 
    @buyer_company = Company.find(params[:q][:company_id_matches]).nickname if params[:q] && params[:q][:company_id_matches].present?
  end
  
  def fees
    @q = Fee.find_type(params[:t]).by_this_seller(current_user.company).filter_period(params[:q]).search(params[:q])
    @all_fees ||= @q.result
    @fees = @all_fees.includes([:entry => [:user, :car_brand, :car_model]], [:line_item => :car_part], [:seller_company], :order).page(params[:page]).per_page(20)

    buyer_present?
    seller_present?
  end

end
