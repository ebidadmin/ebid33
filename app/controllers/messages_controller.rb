class MessagesController < ApplicationController
  load_and_authorize_resource
  
  def index
    @messages = Message.includes(:entry, :user, :user_company, :receiver, :receiver_company).order('created_at DESC').paginate(page: params[:page], per_page: 25)
  end

  def show
    @message = Message.find(params[:id])
  end

  def new
    @message = Message.new
  end

  def create
    @message = current_user.messages.build(params[:message])
    @entry = Entry.find(params[:entry]) unless params[:entry].blank?
    @order = Order.find(params[:order]) unless params[:order].blank?
    @message.create_message(current_user, params[:msg_for], params[:open_tag], @entry, @order, params[:receiver], params[:receiver_company])
    
    unless request.env["HTTP_REFERER"] == new_message_url
      respond_to do |format|
        initialize_messages
        if current_user.messages << @message
          format.html { redirect_to session['referer'], :notice => "Successfully created message."; session['referer'] = nil }
          format.js { flash.now[:notice] = "Message sent." }
          # MessageMailer.delay.message_alert(@entry, @message)
        else
          format.html { render :action => 'new' }
          format.js { flash.now[:notice] = "Message was not sent. Try again!" }
        end
      end    
    else
      current_user.messages << @message
      redirect_to session['referer'], :notice => "Successfully created message."
    end
  end

  def edit
    # raise params.to_yaml
    session['referer'] = request.env["HTTP_REFERER"]
    @message = Message.find(params[:id])
    @entry = params[:entry]
    @order = params[:order] if params[:order]
    @company_type = Role.find(1, 2, 3)
    @company_users = Company.where(:primary_role => [1,2,3]).includes(:users)
    respond_to do |format|
      format.html { render :edit }
      format.js { render :action => "show_fields"}
    end
  end

  def update
    @message = Message.find(params[:id])
    @entry = Entry.find(params[:entry]) unless params[:entry].blank?
    @order = Order.find(params[:order]) unless params[:order].blank?

    unless  request.env["HTTP_REFERER"] == edit_message_url(@message)
      initialize_messages
      respond_to do |format|
        if @message.update_attributes(params[:message])
          format.html { redirect_to session['referer'], :notice => "Successfully updated  message."; session['referer'] = nil }
          format.js { flash.now[:notice] = "Message updated." }
        else
          format.html { render :action => 'edit' }
          format.js { flash.now[:notice] = "Message was not updated. Try again!" }
        end
      end      
    else
      @message.update_attributes(params[:message])
      redirect_to session['referer'], :notice => "Successfully updated message."
    end
  end

  def destroy
    @message = Message.find(params[:id])
    @message.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: "Deleted the message." }
      format.js { flash.now[:notice] = "Deleted the message." }
    end
    
    # redirect_to messages_url, 
  end
  
  def show_fields
    @message = current_user.messages.build(:parent_id => params[:parent_id])
    @msg_for = params[:msg_for]
    @entry = params[:entry]
    @order = params[:order] if params[:order]
  end
  
  def cancel
    @entry = Entry.find(params[:entry])
    @order = Order.find(params[:order]) unless params[:order].blank?
    respond_to do |format| 
      format.html { redirect_to :back }
      format.js 
    end
  end
  
  private
  
  def initialize_messages
    if @order.present?
      if current_user.role?('admin')
        @pvt_messages = @order.messages
      else
        @pvt_messages = @order.messages.pvt.restricted(current_user.company)
      end
    else
      if current_user.role?('admin')
        @pvt_messages = @entry.messages.pvt
      else
        @pvt_messages = @entry.messages.pvt.restricted(current_user.company)
      end
      @pub_messages = @entry.messages.pub
    end
  end
  
end
