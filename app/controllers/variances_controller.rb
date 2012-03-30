class VariancesController < ApplicationController
  skip_before_filter :latest_messages 
  before_filter :check_admin_role, only: [:index]
  before_filter :check_buyer_role
  
  def index
    @variances = Variance.all
  end

  def show
    @entry = Entry.find(params[:entry_id])
    @variance = @entry.variance
    render layout: 'layout2'
  end

  def new
    @entry = Entry.find(params[:entry_id])
    @variance = @entry.build_variance
    @variance.var_items.build
    @var_companies = VarCompany.order(:name).collect { |vc| [vc.name, vc.id.to_i] }
    @available_discounts = Variance::DISCOUNTS.collect { |d| [d + '%', d ] }
    render layout: 'layout2'
  end

  def create
    # raise params.to_yaml
    @entry = Entry.find(params[:entry_id])
    @variance = @entry.build_variance(params[:variance])
    @variance.colonize(current_user, params[:variance][:discount])
    if current_user.variances << @variance
      redirect_to variance_path(id: @variance, entry_id: @entry)
    else
      @var_companies = VarCompany.order(:name).collect { |vc| [vc.name, vc.id] }
      @available_discounts = Variance::DISCOUNTS.collect { |d| [d + '%', d ] }
      render 'new'
    end
    # @variances = Array.new
    # canvasses = params[:items]
    # canvasses.reject! { |k, v| v['amt'].blank? }
    # canvasses.each do |item, canvass_vars|
    #   @variance = Variance.populate(current_user, params[:var_company], params[:discount].to_f, item, canvass_vars)
    #   @entry.variances << @variance
    # end
    # respond_to do |format|
    #   format.html { redirect_to variance_path(id: @entry); flash[:success] = "Generated comparative evaluation." }
    #   format.js
    # end
    
  end

  def edit
    @variance = Variance.find(params[:id])
  end

  def update
    @variance = Variance.find(params[:id])
    if @variance.update_attributes(params[:variance])
      redirect_to @variance, :notice  => "Successfully updated variance."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @variance = Variance.find(params[:id])
    @variance.destroy
    redirect_to variances_url, :notice => "Successfully destroyed variance."
  end
end
