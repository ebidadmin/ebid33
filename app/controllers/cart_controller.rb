class CartController < ApplicationController
  include ActionView::Helpers::TagHelper
  before_filter :initialize_cart

  def add
    @entry = Entry.find(params[:id])
    # @line_items = @entry.line_items.includes(:car_part)
    @item = @cart.add(params[:part])
    @index = @cart.cart_items.count - 1
 
    if request.xhr?
      flash.now[:cart_notice] = "Added #{content_tag :strong, @item.car_part.name}".html_safe
    elsif request.post? 
      flash[:notice] = "Added #{content_tag :strong, @item.car_part.name}".html_safe
      # redirect_to new_user_entry_path(current_user)
    else
      render
    end
  end

  def remove
    @entry = Entry.find(params[:id])
    # @line_items = @entry.line_items.includes(:car_part)
    @item = @cart.remove(params[:part])
    
    if request.xhr?
      flash.now[:cart_notice] = "Removed #{content_tag :strong, @item.car_part.name}".html_safe
      # render :action => "add"
    elsif request.post?
      flash[:cart_notice] = "Removed #{content_tag :strong, @item.car_part.name}".html_safe
      # redirect_to new_user_entry_path(current_user)
    else
      render
    end
  end

  def clear
    @entry = Entry.find(params[:id])
    @line_items = @entry.line_items
    @cart.cart_items.destroy_all

    if request.xhr?
      flash.now[:cart_notice] = "Removed all temporary parts."
    elsif request.post?
      flash.now[:cart_notice] = "Removed all temporary parts."
      # redirect_to new_user_entry_path(current_user)
    else
      render
    end
  end

end
