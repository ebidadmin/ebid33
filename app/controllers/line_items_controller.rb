class LineItemsController < ApplicationController
  # before_filter :check_admin_role, only: [:index]
  # before_filter :check_buyer_role, only: [:index]
  before_filter :initialize_cart, only: [:create, :add, :change]

  def index
    @line_items = LineItem.all
  end

  def show
    @line_item = LineItem.find(params[:id])
  end

  def new
    @line_item = LineItem.new
  end

  def create
    # raise params.to_yaml
    @entry = Entry.find(params[:id])
    if @entry.line_items.blank? && @cart.cart_items.blank? 
      flash[:error] = "Your parts selection is still empty! Choose parts before you proceed."
      redirect_to :back
    else #@entry.line_items.present?
      @line_items = params[:items]
      @specs = params[:specs]
      @entry.add_line_items_from_cart(@cart, @specs, @line_items) 
      respond_to do |format|
        format.html { redirect_to buyer_show_path(@entry), :notice => "Updated your parts list. Next step is to put your entry Online." }
        format.js { flash.now[:cart_notice] = "Updated your parts list. Next step is to attach photos." }
      end      
      # EntryMailer.delay.new_entry_alert(@entry)
    end
  end

  def edit
    session['referer'] = request.env["HTTP_REFERER"]
    @line_item = LineItem.find(params[:id])
  end

  def update
    @line_item = LineItem.find(params[:id])
    if @line_item.update_attributes(params[:line_item])
      redirect_to session['referer'], :notice  => "Successfully updated line item."
      session['referer'] = nil
    else
      render :action => 'edit'
    end
  end

  def destroy
    @line_item = LineItem.find(params[:id])
    @line_item.destroy
    respond_to do |format|
      format.html { redirect_to :back, :notice => "Successfully destroyed line item." }
      format.js
    end
  end
  
  def add
    @entry = Entry.find(params[:id], include: :line_items)
    @car_parts = CarPart.order(:name).page(params[:page]).per_page(32)
    
    render layout: 'layout2'
  end
  
  def cancel
    @entry = Entry.find(params[:id], include: :line_items)
  end
  
end
