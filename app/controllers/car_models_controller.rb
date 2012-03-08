class CarModelsController < ApplicationController
  before_filter :check_admin_role, except: :selected
  
  def index
    @car_models = CarModel.includes(:car_brand).paginate(page: params[:page], per_page: 20)
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

  def selected
    @car_variants = CarVariant.where(car_model_id: params[:id]).order(:name)
    render :partial => 'car_models/selected' 
  end
end
