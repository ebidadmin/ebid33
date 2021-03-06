class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!, unless: :devise_controller?
  # enable_authorization :unless => :devise_controller? 
  before_filter :latest_messages 
  
  rescue_from CanCan::Unauthorized do |exception|
    flash[:error] = exception.message
    if user_signed_in?
      if can? :access, :all # admin
        redirect_to entries_path(s: 'for-decision')
      elsif can? :create, :entries # buyer
        redirect_to buyer_entries_path(s: 'for-decision')
      elsif can? :create, :bids # seller
        redirect_to seller_entries_path(s: 'online') 
      end
    else
      redirect_to root_url
    end
  end
  
  private
  
  def after_sign_in_path_for(resource_or_scope)
    if can? :access, :all #current_user.role?(:admin)
      entries_path(s: 'for-decision')
    elsif can? :create, :entries #current_user.role?(:buyer)
      buyer_entries_path(s: 'for-decision')
    elsif can? :create, :bids #current_user.role?(:seller)
      seller_entries_path(s: 'online') 
    else
      flash[:info] = "You have not been authorized to use E-Bid. Please contact the administrator at 892-5935." 
      root_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def store_location
    session['referer'] = request.env["HTTP_REFERER"]
  end

  def redirect_back_or_default(default)
    redirect_to(session['referer'] || default)
    session['referer'] = nil
  end
  
  def check_role(role) 
    store_location
	  unless current_user && current_user.role?(role) 
	    flash[:error] = "Sorry. You are not authorized for that page or action." 
      if can? :access, :all # admin
        redirect_back_or_default entries_path(s: 'for-decision')
      elsif can? :create, :entries # buyer
        redirect_back_or_default buyer_entries_path(s: 'for-decision')
      elsif can? :create, :bids # seller
        redirect_back_or_default seller_entries_path(s: 'online') 
      end
	  end 
	end 

	def check_admin_role 
	  check_role('admin') 
	end 

	def check_buyer_role 
	  check_role('buyer') 
	end 

	def check_seller_role 
	  check_role('seller') 
	end 
	
  def initialize_cart 
    @cart = Cart.find(session[:cart_id]) 
    rescue ActiveRecord::RecordNotFound 
      @cart = Cart.create#Cart.create(user_id: current_user.id) 
      session[:cart_id] = @cart.id 
  end
 
  
  def search_by_origin
    @car_origins = CarOrigin.includes(:car_brands) # eager loading to make query faster
  end
  
  def search_by_region
    @regions = Region.includes(:cities) # eager loading to make query faster
  end
  
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
      # @seller_company = 'all sellers'
      if (can? :access, :all) || (can? :create, :entries)
         @seller_company = 'all sellers'
       else
         @seller_company = current_user.company.nickname
       end
     end
  end
  
  def latest_messages
    if user_signed_in?
      if can? :access, :all
        @global_messages = Message.includes(:entry, :order).order('created_at DESC').limit(5)
      else
        @global_messages = Message.pvt.where(receiver_company_id: current_user.company).includes(:entry, :order).order('created_at DESC').limit(5)
      end
    end
  end
  
end
