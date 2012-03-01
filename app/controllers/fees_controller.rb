class FeesController < ApplicationController
  def index
    @q = Fee.find_type(params[:t]).filter_period(params[:q]).search(params[:q])
    @all_fees ||= @q.result
    @fees = @all_fees.includes([:entry => [:user, :car_brand, :car_model]], [:line_item => :car_part], [:seller_company], :order).paginate(page: params[:page], per_page: 20)

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
    redirect_to fees_url, :notice => "Successfully destroyed fee."
  end
  
  def bprint
    @q = Fee.for_decline.by_this_buyer(current_user).filter_period(params[:q]).search(params[:q])
    @all_fees ||= @q.result
    @fees = @all_fees.includes([:entry => [:user, :car_brand, :car_model]], [:line_item => :car_part])#.paginate(page: params[:page], per_page: 15)
    
    @buyer_company = current_user.company.nickname
    seller_present?
    render layout: 'print'
  end
  
  private
  
  def seller_present?
    if params[:q] && params[:q][:seller_company_id_matches].present?
      @seller_company = Company.find(params[:q][:seller_company_id_matches])
    end
  end
  
end
