class LineItemsController < ApplicationController
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
    @line_item = LineItem.new(params[:line_item])
    if @line_item.save
      redirect_to @line_item, :notice => "Successfully created line item."
    else
      render :action => 'new'
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
