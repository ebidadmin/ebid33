class CarBrandsController < ApplicationController
  # before_filter :check_admin_role, except: :selected
  
  def index
    @car_brands = CarBrand.includes(:car_origin, :entries)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @car_brands }
    end
  end

  def show
    @car_brand = CarBrand.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @car_brand }
    end
  end

  def new
    @car_brand = CarBrand.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @car_brand }
    end
  end

  def edit
    @car_brand = CarBrand.find(params[:id])
  end

  def create
    @car_brand = CarBrand.new(params[:car_brand])

    respond_to do |format|
      if @car_brand.save
        format.html { redirect_to @car_brand, notice: 'Car brand was successfully created.' }
        format.json { render json: @car_brand, status: :created, location: @car_brand }
      else
        format.html { render action: "new" }
        format.json { render json: @car_brand.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @car_brand = CarBrand.find(params[:id])

    respond_to do |format|
      if @car_brand.update_attributes(params[:car_brand])
        format.html { redirect_to @car_brand, notice: 'Car brand was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @car_brand.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @car_brand = CarBrand.find(params[:id])
    @car_brand.destroy

    respond_to do |format|
      format.html { redirect_to car_brands_url }
      format.json { head :ok }
    end
  end
  
  def selected
    @car_models = CarModel.where(car_brand_id: params[:id]).order(:name)
    render :partial => 'car_brands/selected'
  end
  
end
