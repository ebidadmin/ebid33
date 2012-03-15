class CarPartsController < ApplicationController
  def index
    @car_parts = CarPart.includes(:line_items).page(params[:page]).per_page(20)
  end

  def show
    @car_part = CarPart.find(params[:id])
  end

  def new
    store_location
    @car_part = CarPart.new(creator_id: current_user.id)
  end

  def create
    initialize_cart
    @car_part = CarPart.new(params[:car_part])
    @car_part.creator_id = current_user.id
    if @car_part.save
      @cart.add(@car_part.id)
      @entry = Entry.find(params[:entry])
      flash[:success] = "Successfully created car part."
      redirect_back_or_default(add_line_items_path(id: params[:entry]))
    else
      params[:id] = params[:entry]
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
    @car_parts = CarPart.search(params)
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end
end
