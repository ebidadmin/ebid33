class LineItemsController < ApplicationController
  before_filter :initialize_cart, only: :create

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
      @specs = params[:specs]
      @entry.add_line_items_from_cart(@cart, @specs) 
      respond_to do |format|
        format.html { redirect_to @entry, :notice => "Successfully added parts. Next step is to put your entry Online." }
        format.js { flash.now[:cart_notice] = "Successfully added parts to your entry. Next step is to attach photos." }
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
    redirect_to line_items_url, :notice => "Successfully destroyed line item."
  end
end
