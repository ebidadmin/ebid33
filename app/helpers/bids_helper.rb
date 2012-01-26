module BidsHelper
  def bid_box_helper(item_id, category)
    content_tag :div, class: "cat #{category} center" do
      text_field_tag("bids[#{item_id}][#{category}]", nil, class: 'span3')
    end   
  end
  
  # def bid_box_helper(item_id, category)
  #       text_field_tag("bids[#{item_id}][#{category}]", nil, class: 'span3')
  # end
  
end
