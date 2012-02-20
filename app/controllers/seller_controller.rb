class SellerController < ApplicationController
  
  def entries
    @q ||= Entry.find_status(params[:s]).search(params[:q])
    @entries = @q.result.includes(:user, :photos, :car_brand, :car_model, :line_items, :bids, :city, :term, :messages).paginate(page: params[:page], per_page: 10)
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
    render layout: 'layout2'
  end
  
  def bids
    @q = Bid.unscoped.search(params[:q])
    @bids = @q.result.where(:user_id => current_user.company.users).includes([:entry => [:user, :car_brand, :car_model]], [:line_item => :car_part], :user).order('created_at DESC').paginate(page: params[:page], per_page: 15)
  end
  
  def show
    @entry = Entry.find(params[:id])

    if current_user.role?(:admin)
      @pvt_messages = @entry.messages.pvt
    else
      @pvt_messages = @entry.messages.pvt.restricted(current_user.company)
    end
    @pub_messages = @entry.messages.pub
  end
  
  def orders
    @q = Order.find_status(params[:s]).by_this_seller(current_user.company).search(params[:q])
    @all_orders ||= @q.result
    @orders = @all_orders.includes([:entry => [:car_brand, :car_model, :user]], :company, :messages).paginate :page => params[:page], :per_page => 10
    # generate mailers if FD orders become old
 
    buyer_present?
  end
  
  def fees
    @q = Fee.find_type(params[:t]).by_this_seller(current_user.company).filter_period(params[:q]).search(params[:q])
    @all_fees ||= @q.result
    @fees = @all_fees.includes([:entry => [:user, :car_brand, :car_model]], [:line_item => :car_part], [:seller_company], :order).paginate(page: params[:page], per_page: 20)

    buyer_present?
  end

  private
  
  def buyer_present?
    if params[:q] && params[:q][:company_id_matches].present?
      @buyer_company = Company.find(params[:q][:company_id_matches])
    end
  end
end
