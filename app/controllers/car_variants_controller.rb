class CarVariantsController < ApplicationController
  before_filter :check_admin_role, except: [:new, :create]
  
  layout 'layout2'

  def index
    @brands = CarBrand.all
    @q = CarVariant.search(params[:q])
    @car_variants = @q.result.includes(:car_brand, :car_model, :entries).order(:car_brand_id).paginate(page: params[:page], per_page: 20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @car_variants }
    end
  end

  def show
    @car_variant = CarVariant.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @car_variant }
    end
  end

  def new
    @car_variant = CarVariant.new
    @car_models = []

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @car_variant }
    end
  end

  def edit
    @car_variant = CarVariant.find(params[:id])
    @car_models = CarModel.where(car_brand_id: @car_variant.car_brand_id)
  end

  def create
    # raise params.to_yaml
    @car_variant = CarVariant.new(params[:car_variant])

    respond_to do |format|
      if @car_variant.save
        format.html do
          flash[:success] = "Added new variant."
          if can? :access, :all
            redirect_to :back
          else
            redirect_to new_user_entry_path(current_user, variant: @car_variant )
          end
        end
        format.json { render json: @car_variant, status: :created, location: @car_variant }
      else
        @car_models = CarModel.where(car_brand_id: @car_variant.car_brand_id)
        format.html { render action: "new" }
        format.json { render json: @car_variant.errors, status: :unprocessable_entity }
      end
    end
  end

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

  def destroy
    @car_variant = CarVariant.find(params[:id])
    @car_variant.destroy

    respond_to do |format|
      format.html { redirect_to car_variants_url }
      format.json { head :ok }
    end
  end
end
