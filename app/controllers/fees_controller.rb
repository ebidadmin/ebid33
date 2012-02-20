class FeesController < ApplicationController
  def index
    @q = Fee.search(params[:q])
    @fees = @q.result.includes([:entry => [:user, :car_brand, :car_model]], [:line_item => :car_part], [:seller_company]).paginate(page: params[:page], per_page: 20)
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
end
