class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def search_by_origin
    @car_origins = CarOrigin.includes(:car_brands) # eager loading to make query faster
  end
  
  def search_by_region
    @regions = Region.includes(:cities) # eager loading to make query faster
  end
  
end
