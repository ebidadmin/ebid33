class EntriesController < ApplicationController
  # load_and_authorize_resource
  
  include ActionView::Helpers::TagHelper
  before_filter :check_admin_role, only: [:index]
  before_filter :check_buyer_role
  before_filter :initialize_cart, :only => [:show, :edit]
  before_filter :search_by_origin, only: [:new, :edit, :create, :update]
  before_filter :search_by_region, only: [:new, :edit, :create, :update]
  

  def index
    @q = Entry.search(params[:q])
    @entries = @q.result.find_status(params[:s]).includes(:user, :photos, :car_brand, :car_model, :bids, :city, :term, :messages, :orders).page(params[:page]).per_page(10)
    @branches = Company.where(primary_role: 2).includes(:users => :profile)
  end

  def show
    @entry = Entry.find(params[:id], include: [[:line_items => [:car_part, :bids, :order]], [:messages => [[:user => :roles], [:receiver => :roles]]]])

    if can? :access, :all
      @pvt_messages = @entry.messages.pvt
    else
      @pvt_messages = @entry.messages.pvt.restricted(current_user.company)
    end
    @pub_messages = @entry.messages.pub
  end

  # print sheet
  
  def new
    @entry = current_user.entries.build
    @car_models = @car_variants = @cities = []
    2.times { @entry.photos.build }
    @entry.term_id = 4 # default credit term is 30 days
    if params[:variant]
      @saved_variant = CarVariant.find(params[:variant])
      @entry.car_brand_id = @saved_variant.car_brand_id
      @car_models = CarModel.where(car_brand_id: @entry.car_brand_id)
      @entry.car_model_id = @saved_variant.car_model_id
      @car_variants = CarVariant.where(car_model_id: @entry.car_model_id)
      @entry.car_variant_id = @saved_variant.id
    end
    render layout: 'layout2'
  end

  def create
    # raise params.to_yaml
    @entry = current_user.entries.build(params[:entry])
    if current_user.company.entries << @entry
      flash[:success] = "Successfully created entry. Next step is to search and add parts."
      if current_user.role?(:buyer)
        redirect_to buyer_show_path(@entry)
      else
        redirect_to @entry
      end
    else
      @car_models = CarModel.where(car_brand_id: @entry.car_brand_id)
      @car_variants = CarVariant.where(car_model_id: @entry.car_model_id)
      @entry.region = params[:entry][:region]
      @cities = params[:entry][:region].present? ? City.where(region_id: @entry.region) : []
      @entry.term_id = params[:entry][:term_id]
      # 2.times { @entry.photos.build }
      # flash[:error] = "Looks like you forgot to complete the required vehicle info.  Try again!"
      render 'new'
    end
  end

  def edit
    session['referer'] = request.env["HTTP_REFERER"]
    @entry = Entry.find(params[:id])
    @car_models = CarModel.where(car_brand_id: @entry.car_brand_id)
    @car_variants = CarVariant.where(car_model_id: @entry.car_model_id)
    @entry.region = @entry.city.region_id
    @cities = City.where(region_id: @entry.region)
    @entry.photos.build if @entry.photos.nil?
    render layout: 'layout2'
  end

  def update
    # raise params.to_yaml
    @entry = Entry.find(params[:id])
    if @entry.update_attributes(params[:entry])
      flash[:notice] = "Successfully updated entry."
      # redirect_to session['referer'], :notice  => "Successfully updated entry."
      flash[:success] = "Successfully created entry. Next step is to search and add parts."
      if current_user.role?(:buyer)
        redirect_to buyer_show_path(@entry)
      else
        redirect_to @entry
      end
    else
      @car_models = CarModel.where(car_brand_id: @entry.car_brand_id)
      @car_variants = CarVariant.where(car_model_id: @entry.car_model_id)
      @entry.region = @entry.city.region_id
      @cities = City.where(region_id: @entry.region)
      @entry.photos.build if @entry.photos.nil?
      render 'edit'
    end
  end

  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy
    redirect_to entries_url, :notice => "Successfully destroyed entry."
  end
  
  def put_online
    @entry = Entry.find(params[:id], include: [:line_items => :car_part])
    if @entry#.can_online
      flash[:success] = @entry.put_online 
      redirect_to :back
    else
      flash[:error] = "Wait! Your entry is not yet complete. Please complete the photos and parts before you proceed."
      redirect_to :back
    end
  end

  def relist
    @entry = Entry.find(params[:id])
    if @entry.can_relist || @entry.has_additionals
      flash[:success] = @entry.relist
      redirect_to :back
    else
      flash[:error] = "Sorry, there are no items to relist."
      redirect_to :back
    end
  end
  
  def reveal 
    @entry = Entry.find(params[:id])
    unless @entry.bids.blank?
      flash[:success] = @entry.reveal
    else
      flash[:warning] = "Sorry, there no bids to reveal."
    end 
    redirect_to :back
  end
  
end
