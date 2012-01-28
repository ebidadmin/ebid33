module BidsHelper
  def bid_box_helper(item_id, category)
    content_tag :div, class: "cat #{category} center" do
      text_field_tag("bids[#{item_id}][#{category}]", nil, class: 'span3')
    end   
  end

  def bid_amount_helper(bid, f=nil)
    content_tag :p do
      if f.present?
        ((f.radio_button 'id', bid.id) + 
        (content_tag :span, currency(bid.amount), class: 'bid-amount') + 
        (content_tag :em, bid.user.username, class: 'small')).html_safe
      else
        ((content_tag :span, currency(bid.amount), class: 'bid-amount') + 
        (content_tag :em, bid.user.username, class: 'small')).html_safe
      end
    end 
  end
  
  def bid_quantity_helper(bid, action) # used in bids/accept
    if action == 'show'
      bid.quantity
    else
      text_field_tag "bids[#{bid.id}][]", bid.quantity, class: 'span1'
    end
  end
  
end
