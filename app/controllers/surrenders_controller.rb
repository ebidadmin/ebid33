class SurrendersController < ApplicationController
  skip_before_filter :latest_messages
  layout 'layout2'
  
  def index
    @surrenders = Surrender.all
  end

  def show
    @surrender = Surrender.find(params[:id], include: [:surrender_parts => :car_part])
    @entry =  @surrender.entry
    render layout: 'print'
  end

  def new
    @entry = Entry.find(params[:id], include: [:line_items => :car_part])
    @surrender = @entry.surrenders.build
  end

  def create
    # raise params.to_yaml
    @entry = Entry.find(params[:id])
    @surrender = @entry.surrenders.build(params[:surrender])
    if @surrender.save
      @li = LineItem.find(params[:items])
      @li.each do |i|
        @surrender.surrender_parts.create!(line_item_id: i.id, car_part_id: i.car_part_id)
      end
      redirect_to @surrender
    else
      render :action => 'new'
    end
  end

  def edit
    @surrender = Surrender.find(params[:id], include: [:entry => [:line_items => :car_part]])
    @entry =  @surrender.entry
  end

  def update
    @surrender = Surrender.find(params[:id])
    if @surrender.update_attributes(params[:surrender])
      redirect_to @surrender, :notice  => "Successfully updated surrender."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @surrender = Surrender.find(params[:id])
    @surrender.destroy
    redirect_to surrenders_url, :notice => "Successfully destroyed surrender."
  end
end
