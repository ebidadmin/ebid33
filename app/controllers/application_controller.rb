class ApplicationController < ActionController::Base
  protect_from_forgery
  enable_authorization :unless => :devise_controller? 
  layout 'seller'
  
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
  
  def initialize_cart 
    @cart = Cart.find(session[:cart_id]) 
    rescue ActiveRecord::RecordNotFound 
      @cart = Cart.create#Cart.create(user_id: current_user.id) 
      session[:cart_id] = @cart.id 
  end
  
end
