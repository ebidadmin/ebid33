class CarBrandsController < ApplicationController
  # GET /car_brands
  # GET /car_brands.json
  def index
    @car_brands = CarBrand.scoped.includes(:car_origin)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @car_brands }
    end
  end

  # GET /car_brands/1
  # GET /car_brands/1.json
  def show
    @car_brand = CarBrand.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @car_brand }
    end
  end

  # GET /car_brands/new
  # GET /car_brands/new.json
  def new
    @car_brand = CarBrand.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @car_brand }
    end
  end

  # GET /car_brands/1/edit
  def edit
    @car_brand = CarBrand.find(params[:id])
  end

  # POST /car_brands
  # POST /car_brands.json
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

  # PUT /car_brands/1
  # PUT /car_brands/1.json
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

  # DELETE /car_brands/1
  # DELETE /car_brands/1.json
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
