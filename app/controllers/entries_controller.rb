class EntriesController < ApplicationController
  include ActionView::Helpers::TagHelper
  before_filter :search_by_origin, only: [:new, :edit, :create, :update]
  before_filter :search_by_region, only: [:new, :edit, :create, :update]

  def index
    @entries = Entry.find_status(params[:s]).includes(:user, :photos, :car_brand, :car_model, :bids, :city, :term).paginate(page: params[:page], per_page: 12).order('created_at DESC')
  end

  def show
    @entry = Entry.find(params[:id], include: [:line_items => [:car_part, [:bids => :user]]])
    # @entry = Entry.find(params[:id], include: [:line_items => :car_part])
    @q = CarPart.search(params[:q])
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
  
  def put_online
    @entry = Entry.find(params[:id], include: [:line_items, :bids])
    @line_items = @entry.line_items
    
    if @line_items.fresh.present? #&& @entry.photos.present?
      if @entry.update_attributes(status: "Online", online: Time.now, bid_until: 1.week.from_now)
        @entry.update_associated_status("Online")
        flash[:notice] = "Your entry is #{content_tag :strong, 'now online'}. Thanks!".html_safe
      end
      redirect_to :back
      # @entry.send_online_notification
    else
      flash[:error] = "Wait! Your entry is not yet complete. Please complete the photos and parts before you proceed."
      redirect_to :back
    end
  end
  
  def reveal 
    @entry = Entry.find(params[:id], include: [:line_items, :bids])
    unless @entry.bids.blank?
      if @entry.update_attributes(status: "For-Decision", decided: Date.today)
        for item in @entry.line_items.online#.includes(:bids, :order_item)
          item.update_for_decision #unless item.order_item.present?
        end
        flash[:notice] = "Bidding is now finished. Bids are revealed below. You can proceed to Create PO.".html_safe
      end
    else
      flash[:warning] = "Sorry, there no bids to reveal."
    end 
    redirect_to @entry
  end
  
end
