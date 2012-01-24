class RegionsController < ApplicationController
  def selected
    @cities = City.where(region_id: params[:id])
    render :partial => 'regions/selected'
  end

end
