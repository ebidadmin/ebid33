class CitiesController < ApplicationController
  def index
    @cities = City.includes(:entries).page(params[:page]).per_page(30)
  end

  def show
    @city = City.find(params[:id])
  end

  def new
    store_location
    # @city = City.new
    @city = current_user.cities.new
  end

  def create
    @city = City.new(params[:city])
    if current_user.cities << @city#.save
      # redirect_to @city, :notice => "Successfully created city."
      redirect_back_or_default(cities_path)
    else
      render :action => 'new'
    end
  end

  def edit
    store_location
    @city = City.find(params[:id])
    render layout: 'layout2'
  end

  def update
    @city = City.find(params[:id])
    if @city.update_attributes(params[:city])
      # redirect_to @city, :notice  => "Successfully updated city."
      redirect_back_or_default(cities_path)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @city = City.find(params[:id])
    @city.destroy
    redirect_to cities_url, :notice => "Successfully destroyed city."
  end
end
