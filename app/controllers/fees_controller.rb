class FeesController < ApplicationController
  def index
    @q = Fee.find_type(params[:t]).filter_period(params[:q]).search(params[:q])
    @all_fees ||= @q.result
    @fees = @all_fees.includes([:entry => [:user, :car_brand, :car_model]], [:line_item => :car_part], [:seller_company], :order).paginate(page: params[:page], per_page: 20)
    
    buyer_present?
    seller_present?
  end

  def show
    @fee = Fee.find(params[:id])
  end

  def new
    @fee = Fee.new
  end

  def create
    @fee = Fee.new(params[:fee])
    if @fee.save
      redirect_to @fee, :notice => "Successfully created fee."
    else
      render :action => 'new'
    end
  end

  def edit
    @fee = Fee.find(params[:id])
  end

  def update
    @fee = Fee.find(params[:id])
    if @fee.update_attributes(params[:fee])
      redirect_to @fee, :notice  => "Successfully updated fee."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @fee = Fee.find(params[:id])
    @fee.destroy
    respond_to do |format|
      format.html { redirect_to :back, :notice => "Deleted fee." }
      format.js
    end
  end
  
  def print
    if can? :access, :all
      @q = Fee.find_type(params[:t]).filter_period(params[:q]).search(params[:q])
    elsif can? :create, :entries
      @q = Fee.for_decline.by_this_buyer(current_user).filter_period(params[:q]).search(params[:q])
    elsif can? :create, :bids #current_user.role?(:seller)
      @q = Fee.find_type(params[:t]).by_this_seller(current_user.company).filter_period(params[:q]).search(params[:q])
    end
    @all_fees ||= @q.result
    @fees = @all_fees.includes([:entry => [:user, :car_brand, :car_model]], [:line_item => :car_part], :seller_company)#.paginate(page: params[:page], per_page: 15)
    
    buyer_present?
    seller_present?
    render layout: 'print'
  end
  
end
