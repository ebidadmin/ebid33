class EntriesController < ApplicationController
  load_and_authorize_resource
  
  include ActionView::Helpers::TagHelper
  before_filter :initialize_cart, :only => [:show, :edit]
  before_filter :search_by_origin, only: [:new, :edit, :create, :update]
  before_filter :search_by_region, only: [:new, :edit, :create, :update]
  

  def index
    # @entries = current_user.entries.find_status(params[:s]).includes(:user, :photos, :car_brand, :car_model, :bids, :city, :term).paginate(page: params[:page], per_page: 12).order('created_at DESC')
    @q = Entry.search(params[:q])
    @entries = @q.result.find_status(params[:s]).includes(:user, :photos, :car_brand, :car_model, :bids, :city, :term).paginate(page: params[:page], per_page: 10).order('created_at DESC')
    # @branches = Company.where(primary_role: 2).map { |c| c.branches }#Branch.includes(:users => :profile)
  end

  def show
    @entry = Entry.find(params[:id], include: [:messages => [[:user => :roles], [:receiver => :roles]]])
    @q = CarPart.search(params[:q])

    if current_user.role?(:admin)
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
  end

  def create
    @entry = current_user.entries.build(params[:entry])
    if current_user.company.entries << @entry
      flash[:notice] = "Successfully created entry."
      if current_user.role?(:buyer)
        redirect_to buyer_show_path(@entry)
      else
        redirect_to @entry
      end
    else
      flash[:error] = "Looks like you forgot to complete the required vehicle info.  Try again!"
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
  end

  def update
    # raise params.to_yaml
    @entry = Entry.find(params[:id])
    if @entry.update_attributes(params[:entry])
      redirect_to session['referer'], :notice  => "Successfully updated entry."
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
    @entry = Entry.find(params[:id], include: [:line_items => :bids])
    unless @entry.bids.blank?
      if @entry.update_attributes(status: "For-Decision", decided: Time.now)
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
  
  def relist
    @entry = Entry.find(params[:id])
    @line_items = @entry.line_items
    unless @line_items.without_bids.blank?
      if @line_items.relistable.present?
        @line_items.relistable.update_all(status: 'Relisted', relisted: Time.now)
        @entry.update_attributes(status: 'Relisted', bid_until: 1.week.from_now, relisted: Time.now, relist_count: @entry.relist_count += 1, chargeable_expiry: nil, expired: nil)
        flash[:notice] = "The items without bids have been re-listed and available again for bidding.".html_safe
      end
      if @line_items.fresh.present?
        @line_items.fresh.update_all(status: 'Online')
        @entry.update_attributes(status: 'Additional', bid_until: 1.week.from_now, relisted: Time.now, relist_count: @entry.relist_count += 1, chargeable_expiry: nil, expired: nil)
        flash[:notice] = "New parts are now online and available for bidding.".html_safe
      end
      redirect_to buyer_show_path(@entry)#@entry
    else
      flash[:error] = "Sorry, there are no items to relist."
      redirect_to :back
    end
    # for friend in @entry.user.company.friends
    #   unless friend.users.nil?
    #     for seller in friend.users
    #       EntryMailer.delay.relisted_entry_alert(seller, @entry) if seller.opt_in == true
    #     end
    #   end
    # end
  end
  
end
