module CartHelper
  def select_link(car_part, entry = nil)
    # (car_part.name + (link_to "+", cart_add_path(part: car_part, id: entry), class: 'btn floatright', remote: true)).html_safe
    link_to(car_part.name, cart_add_path(part: car_part, id: entry), remote: true)
  end
  
  def remove_link(car_part, entry = nil)
    content_tag :span, (link_to  "x", cart_remove_path(part: car_part, id: entry), class: 'remove-link floatright', remote: true)
  end

  def clear_cart_link(entry = nil)
    link_to "Remove All Parts", cart_clear_path(:id => entry), class: 'btn floatleft', remote: true
  end 
  
  def save_cart_link(entry = nil)
    link_to 'Save Parts List', line_items_path(:id => @entry), class: 'btn success floatright'
  end
  
end
