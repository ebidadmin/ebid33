class BidsController < ApplicationController
  # load_and_authorize_resource
  before_filter :check_admin_role, only: [:index]
  before_filter :check_buyer_role, only: [:accept]
  before_filter :check_seller_role, except: [:index, :accept]
  
  def index
    # @bids = Bid.unscoped.includes([:entry => [:user, :car_brand, :car_model]], [:line_item => :car_part], :user).order('created_at DESC').paginate(page: params[:page], per_page: 30)
    @q = LineItem.with_bids.search(params[:q])
    @line_items = @q.result.includes([:entry => [:car_brand, :car_model, :user]]).order('created_at DESC').paginate(page: params[:page], per_page: 20)
  end

  def show
    @bid = Bid.find(params[:id])
  end

  def new
    @bid = Bid.new
  end

  def create
    # raise params.to_yaml
    @entry = Entry.find(params[:entry_id])
    @new_bids = Array.new
    @valid_bids = Array.new
    @existing_bids = Array.new
    submitted_bids = params[:bids]
    submitted_bids.each do |line_item, bidtypes|
      bidtypes.reject! { |k, v| v.blank? }
      bidtypes.each do |bid|
        @line_item = LineItem.find(line_item)
        @existing_bid = Bid.find_by_user_id_and_line_item_id_and_bid_type(current_user.company.users, line_item, bid[0])
        if @existing_bid.nil? 
          @new_bid = Bid.populate(current_user, @entry, @line_item, bid[1], bid[0])
          @new_bids << @new_bid 
          @valid_bids << @new_bid if @new_bid.valid?
        else
          @existing_bid.repopulate(current_user, bid[1], @line_item.quantity)
          @existing_bids << @existing_bid 
          @valid_bids << @existing_bid if @existing_bid.valid?
        end
      end
    end
    if @valid_bids.compact.length > 0 
      @valid_bids.each(&:save!)
      Notify.delay.bids_submitted(@valid_bids, @entry, current_user)#.deliver 
    end
    respond_to do |format|
      format.html { redirect_to :back; flash[:notice] = "Bids submitted. Thank you!" }
      format.js 
    end      
  end

  def edit
    session['referer'] = request.env["HTTP_REFERER"]
    @bid = Bid.find(params[:id])
  end

  def update
    @bid = Bid.find(params[:id])
    if @bid.update_attributes(params[:bid])
      redirect_to session['referer'], :notice => 'Bid successfully updated.'
      session['referer'] = nil
    else
      render :action => 'edit'
    end
  end

  def destroy
    @bid = Bid.find(params[:id])
    @bid.destroy
    respond_to do |format|
      format.html { redirect_to :back, :notice => "Deleted bid." }
      format.js
    end
  end
  
  def accept
    session['referer'] = request.env["HTTP_REFERER"]
    unless params[:bids].blank?
      @entry = Entry.find(params[:entry_id])
      @bids = Bid.find(params[:bids].collect { |item, id| id.values }, include: [:line_item => :car_part])
      @bidders = @bids.collect(&:user_id).uniq
      @order = @entry.orders.build
      # @order = current_user.orders.build
      render layout: 'layout2'
    else
      flash[:error] = ("Ooops! Select the <strong>Low Bids</strong> first before you create a PO.").html_safe
      redirect_to :back
    end
  end
  
end
