class CarPartsController < ApplicationController
  def index
    @car_parts = CarPart.all
  end

  def show
    @car_part = CarPart.find(params[:id])
  end

  def new
    @car_part = CarPart.new
  end

  def create
    @car_part = CarPart.new(params[:car_part])
    if @car_part.save
      redirect_to @car_part, :notice => "Successfully created car part."
    else
      render :action => 'new'
    end
  end

  def edit
    @car_part = CarPart.find(params[:id])
  end

  def update
    @car_part = CarPart.find(params[:id])
    if @car_part.update_attributes(params[:car_part])
      redirect_to @car_part, :notice  => "Successfully updated car part."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @car_part = CarPart.find(params[:id])
    @car_part.destroy
    redirect_to car_parts_url, :notice => "Successfully destroyed car part."
  end

  def search
    @entry = Entry.find(params[:id])
    # @search = CarPart.name_like_all(params[:query].to_s.split).order(:name)
    # @car_parts = @search.paginate(page: params[:page], per_page: 12)
    @q = CarPart.search(params[:q])
    @car_parts = @q.result.paginate(page: params[:page], per_page: 24)
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end
end
