class RegionsController < ApplicationController
  def selected
    @cities = City.where(region_id: params[:id]).order(:name)
    render :partial => 'regions/selected'
  end

end
