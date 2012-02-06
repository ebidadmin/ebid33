class CarVariantsController < ApplicationController
  # GET /car_variants
  # GET /car_variants.json
  def index
    @car_variants = CarVariant.includes(:car_brand, :car_model).paginate(page: params[:page], per_page: 20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @car_variants }
    end
  end

  # GET /car_variants/1
  # GET /car_variants/1.json
  def show
    @car_variant = CarVariant.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @car_variant }
    end
  end

  # GET /car_variants/new
  # GET /car_variants/new.json
  def new
    @car_variant = CarVariant.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @car_variant }
    end
  end

  # GET /car_variants/1/edit
  def edit
    @car_variant = CarVariant.find(params[:id])
  end

  # POST /car_variants
  # POST /car_variants.json
  def create
    @car_variant = CarVariant.new(params[:car_variant])

    respond_to do |format|
      if @car_variant.save
        format.html { redirect_to @car_variant, notice: 'Car variant was successfully created.' }
        format.json { render json: @car_variant, status: :created, location: @car_variant }
      else
        format.html { render action: "new" }
        format.json { render json: @car_variant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /car_variants/1
  # PUT /car_variants/1.json
  def update
    @car_variant = CarVariant.find(params[:id])

    respond_to do |format|
      if @car_variant.update_attributes(params[:car_variant])
        format.html { redirect_to @car_variant, notice: 'Car variant was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @car_variant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /car_variants/1
  # DELETE /car_variants/1.json
  def destroy
    @car_variant = CarVariant.find(params[:id])
    @car_variant.destroy

    respond_to do |format|
      format.html { redirect_to car_variants_url }
      format.json { head :ok }
    end
  end
end
