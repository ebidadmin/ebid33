class CarModelsController < ApplicationController
  def index
    @car_models = CarModel.scoped.includes(:car_brand)
  end

  def show
    @car_model = CarModel.find(params[:id])
  end

  def new
    @car_model = CarModel.new
  end

  def create
    @car_model = CarModel.new(params[:car_model])
    if @car_model.save
      redirect_to @car_model, :notice => "Successfully created car model."
    else
      render :action => 'new'
    end
  end

  def edit
    @car_model = CarModel.find(params[:id])
  end

  def update
    @car_model = CarModel.find(params[:id])
    if @car_model.update_attributes(params[:car_model])
      redirect_to @car_model, :notice  => "Successfully updated car model."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @car_model = CarModel.find(params[:id])
    @car_model.destroy
    redirect_to car_models_url, :notice => "Successfully destroyed car model."
  end
end
