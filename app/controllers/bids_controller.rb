class BidsController < ApplicationController
  # after_create :send_email
  
  def index
    @bids = Bid.all
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
    @line_items = Array.new
    @new_bids = Array.new
    @existing_bids = Array.new
    @submitted_bids = params[:bids]
    @submitted_bids.each do |line_item, bidtypes|
      bidtypes.reject! { |k, v| v.blank? }
      bidtypes.each do |bid|
        unless bid[1].to_f < 1
          # @company = current_user.company
          @line_item = LineItem.find(line_item)
          @existing_bid = Bid.find_by_user_id_and_line_item_id_and_bid_type(current_user, line_item, bid[0])
          # @existing_bid = Bid.find_by_user_id_and_line_item_id_and_bid_type(@company.users, line_item, bid[0])
          if @existing_bid.nil? 
            @new_bid = Bid.populate(current_user, @entry, @line_item, bid[1], bid[0])
            @new_bids << @new_bid unless @new_bid.amount < 1
          else
            if @existing_bid.user != current_user
              @existing_bid.update_attributes!(:user_id => current_user.id, :amount => bid[1], :total => bid[1].to_f * @line_item.quantity.to_i, :status => 'Updated')
            else
              @existing_bid.update_attributes!(:amount => bid[1], :total => bid[1].to_f * @line_item.quantity.to_i, :status => 'Updated')
            end
            @existing_bids << @existing_bid unless @existing_bid.amount < 1
          end
          @line_items << @line_item 
        end
      end
    end
    if @new_bids.compact.length > 0 && @new_bids.all?(&:valid?)
      @new_bids.each(&:save!)
      # BidMailer.delay.bid_alert(@new_bids, @entry) 
      # BidMailer.delay.bid_alert_to_admin(@new_bids, @entry, current_user)
      flash[:notice] = "Bids submitted. Thank you!"
    end
    if @existing_bids.compact.length > 0
      # BidMailer.delay.bid_alert_to_admin(@existing_bids, @entry, current_user, 1)
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.js 
    end      
  end

  def edit
    @bid = Bid.find(params[:id])
  end

  def update
    @bid = Bid.find(params[:id])
    if @bid.update_attributes(params[:bid])
      redirect_to @bid, :notice  => "Successfully updated bid."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @bid = Bid.find(params[:id])
    @bid.destroy
    redirect_to bids_url, :notice => "Successfully destroyed bid."
  end
  
  private
  
  # def send_email
  #   
  # end
end
