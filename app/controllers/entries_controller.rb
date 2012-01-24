class EntriesController < ApplicationController
  before_filter :search_by_origin, only: [:new, :edit, :create, :update]
  before_filter :search_by_region, only: [:new, :edit, :create, :update]

  def index
    @entries = Entry.paginate(page: params[:page], per_page: 12).order('created_at DESC')
  end

  def show
    @entry = Entry.find(params[:id])
  end

  def new
    @entry = Entry.new
    @car_models = @car_variants = @cities = []
    2.times { @entry.photos.build }
    @entry.term_id = 4 # default credit term is 30 days
  end

  def create
    @entry = Entry.new(params[:entry])
    if @entry.save
      redirect_to @entry, :notice => "Successfully created entry."
    else
      render :action => 'new'
    end
  end

  def edit
    @entry = Entry.find(params[:id])
    @car_models = CarModel.where(car_brand_id: @entry.car_brand_id)
    @car_variants = CarVariant.where(car_model_id: @entry.car_model_id)
    @entry.region = @entry.city.region_id
    @cities = City.where(region_id: @entry.region)
    @entry.photos.build
  end

  def update
    @entry = Entry.find(params[:id])
    if @entry.update_attributes(params[:entry])
      redirect_to @entry, :notice  => "Successfully updated entry."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy
    redirect_to entries_url, :notice => "Successfully destroyed entry."
  end
end
