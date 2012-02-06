module BidsHelper
  def bid_box_helper(item_id, category)
    content_tag :div, class: "cat #{category} center" do
      text_field_tag("bids[#{item_id}][#{category}]", nil, class: 'span3')
    end   
  end

  def bid_amount_helper(bid, f=nil)
    content_tag :p, class: "#{bid.status_color}" do
      if f.present?
        ((f.radio_button 'id', bid.id) + 
        (content_tag :span, currency(bid.amount), class: 'bid-amount') + 
        (content_tag :em, bid.user.username, class: 'small')).html_safe
      else
        # ((content_tag :span, currency(bid.amount), class: 'bid-amount') + 
        ((content_tag :span, link_to(currency(bid.amount), edit_bid_path(bid)), class: 'bid-amount') + 
        (content_tag :em, bid.user.username, class: 'small')).html_safe
      end
    end 
  end
  
  def bid_quantity_helper(bid, action) # used in bids/accept
    if action == 'show' || action == 'cancel'
      bid.quantity
    else
      text_field_tag "bids[#{bid.id}][]", bid.quantity, class: 'span1 center'
    end
  end
  
  def check_box_helper(bid, order, user, action)
    if action == 'cancel'
      checker = true
    elsif bid.cancelled?
      checker = false
    else
      checker = true
    end
    check_box_tag 'bid_ids[]', bid.id, checker if order.can_be_cancelled(user, action)
  end
  
  def total_label_helper(bids, action)
    if action == 'cancel' || action == 'edit'
      "For Cancellation (#{pluralize bids.count, 'part'})"
    else
      "Total (#{pluralize bids.not_cancelled.count, 'part'})"
    end
  end
  
  def total_amount_helper(bids, action)
    if action == 'cancel' || action == 'edit'
      ph_currency(bids.collect(&:total).sum)
    else
      ph_currency(bids.not_cancelled.collect(&:total).sum)
    end
  end
  
  def display_bid_helper(bid, type)
    if bid.bid_type == type
      render bid 
    else
      ''
    end
    # link_to("PO# #{bid.order_id}", bid.order) if bid && bid.order
  end
  
end
