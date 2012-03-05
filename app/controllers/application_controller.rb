class ApplicationController < ActionController::Base
  protect_from_forgery
  # enable_authorization :unless => :devise_controller? 
  before_filter :latest_messages 
  
  rescue_from CanCan::Unauthorized do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end
  
  def search_by_origin
    @car_origins = CarOrigin.includes(:car_brands) # eager loading to make query faster
  end
  
  def search_by_region
    @regions = Region.includes(:cities) # eager loading to make query faster
  end
  
  private
  
  def after_sign_in_path_for(resource_or_scope)
    if current_user.role?(:admin)
      entries_path
    elsif current_user.role?(:buyer)
      buyer_entries_path(s: 'for-decision')
    elsif current_user.role?(:seller)
      seller_entries_path(s: 'online') 
    else
      flash[:info] = "You have not been authorized to use E-Bid. Please contact the administrator at 892-5935." 
      root_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def initialize_cart 
    @cart = Cart.find(session[:cart_id]) 
    rescue ActiveRecord::RecordNotFound 
      @cart = Cart.create#Cart.create(user_id: current_user.id) 
      session[:cart_id] = @cart.id 
  end
 
  private
  
  def buyer_present?
    if params[:q] && params[:q][:buyer_company_id_matches].present?
      @buyer_company = Company.find(params[:q][:buyer_company_id_matches]).nickname
    else
      if can? :access, :bids
        @buyer_company = 'all buyers'
      else
        @buyer_company = current_user.company.nickname
      end
    end
  end
 
  def seller_present?
    if params[:q] && params[:q][:seller_company_id_matches].present?
      @seller_company = Company.find(params[:q][:seller_company_id_matches]).nickname
    else
      @seller_company = 'all sellers'
      # if can? :access, :all
      #   @seller_company = 'all sellers'
      # else
      #   @seller_company = current_user.company.nickname
      # end
    end
  end
  
  def latest_messages
    if user_signed_in?
    @global_messages = Message.pvt.where(receiver_company_id: current_user.company).order('created_at DESC').limit(5)
    end
  end
  
end
