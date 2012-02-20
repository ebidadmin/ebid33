module BidsHelper
  def bid_box_helper(item_id, category)
    content_tag :div, class: "cat #{category} center" do
      text_field_tag("bids[#{item_id}][#{category}]", nil)
    end   
  end

  def bid_amount_helper(bid, f=nil)
    content_tag :p, class: "#{bid.status_color}" do
      if f.present?
        ((f.radio_button 'id', bid.id) + 
        (content_tag :span, currency(bid.amount), class: 'bid-amount') + 
        (content_tag :em, bid.user.username, class: 'small')).html_safe
      else
        ((content_tag :span, currency(bid.amount), class: 'bid-amount') + 
        # ((content_tag :span, link_to(currency(bid.amount), edit_bid_path(bid)), class: 'bid-amount') + 
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
      "Total (#{pluralize bids.count, 'part'})"
    end
  end
  
  def total_amount_helper(bids, action)
    if action == 'cancel' || action == 'edit'
      ph_currency(bids.collect(&:total).sum)
    else
      ph_currency(bids.collect(&:total).sum)
    end
  end
  
  def display_bid_helper(bids, type)
		content_tag :td, class: 'span2 center bids' do
		 bids.map {|b| b if b.bid_type == type }.each do |bid|
		   "#{render bid if bid}"
		 end
    end
  end
  
  def supplier_bid_rate(entry, bids)
    if bids.present?
  	  "#{bids.collect(&:line_item_id).uniq.count} out of #{pluralize entry.line_items.size, 'item'}"
	  else
	    content_tag :span, "You have no bids", class: 'highlight'
    end
  end
  
end
