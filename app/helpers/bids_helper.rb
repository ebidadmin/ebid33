module BidsHelper
  def bid_box_helper(item_id, category)
    # content_tag :div, class: "cat #{category[0]} center" do
      text_field_tag("bids[#{item_id}][#{category}]", nil)
    # end   
  end

  def bid_amount_helper(bid, f=nil)
    content_tag :p, class: "#{bid.status_color}" do
      amount = content_tag :span, currency(bid.amount), class: 'bid-amount'
      editable_amount = content_tag :span, link_to(currency(bid.amount), edit_bid_path(bid)), class: 'bid-amount'
      display_name = content_tag :em, bid.user.username, class: 'small'

      if can? :access, :all
        editable_amount + display_name
      elsif f.present?
        (f.radio_button 'id', bid.id) + amount + display_name
      else
        amount + display_name
      end
    end 
  end
  
  def bid_quantity_helper(bid, action) # used in bids/accept
    if action == 'show' || action == 'cancel'
      bid.quantity
    elsif bid.cancelled?
      nil
    else
      text_field_tag "bids[#{bid.id}][]", bid.quantity, class: 'span1 txtcenter'
    end
  end
  
  def check_box_helper(bid, order, user, action)
    if (action == 'cancel' || action == 'show') && order.can_be_cancelled(user)
      bid.cancelled? ? nil : check_box_tag('bid_ids[]', bid.id, true)
    end
  end
  
  def total_label_helper(order, bids=nil, action=nil)
    case action
    when 'cancel' then "For Cancellation (#{pluralize bids.count, 'part'})"
    when 'accept' then "Total (#{pluralize bids.count, 'part'})"
    else "Total (#{pluralize order.bids.not_cancelled.count, 'part'})"
    end
  end
  
  def total_amount_helper(order, bids=nil, action=nil)
    case action
    when 'cancel', 'accept' then ph_currency(bids.collect(&:total).sum)
    else ph_currency(order.bids.not_cancelled.collect(&:total).sum)
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
