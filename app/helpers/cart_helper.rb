module CartHelper
  def select_link(car_part, entry = nil)
    # (car_part.name + (link_to "+", cart_add_path(part: car_part, id: entry), class: 'btn floatright', remote: true)).html_safe
    link_to "#{car_part.highlight.name[0]}".html_safe, cart_add_path(part: car_part, id: entry), remote: true
  end
  
  def remove_link(car_part, entry = nil)
    content_tag :span, (link_to  '&times;'.html_safe, cart_remove_path(part: car_part, id: entry), rel: 'tooltip', data: {'original-title' => 'delete part'}, class: 'remove-link floatright close', remote: true)
  end

  def clear_cart_link(entry = nil)
    link_to "Clear Parts List", cart_clear_path(:id => entry), class: 'btn clear', remote: true
  end 
  
  def save_cart_link(entry = nil)
    link_to 'Save Parts List', line_items_path(:id => @entry), class: 'btn success floatright' 
  end
  
  # for deleting existing item in Entry#Edit
  def delete_link(item)
    content_tag :span, (link_to  '&times;'.html_safe, item, confirm: "Are you sure you want to delete #{item.part_name}?", method: :delete, rel: 'tooltip', data: {'original-title' => 'delete part'}, class: 'remove-link floatright close', remote: true) if item.is_deleteable
  end
  
  def cart_rules_helper(bad_desc, good_desc=nil, specs=nil)
    (content_tag :p, class: 'bad-p' do
      content_tag(:span, "Bad", class: 'label label-important') + 
      content_tag(:span, bad_desc, class: 'bad-code')
    end) + 
    (content_tag :p, class: 'good-p' do
      content_tag(:span, "Good", class: 'label label-success') + 
      content_tag(:code, good_desc, class: 'good-code') + 
      (content_tag(:em, "#{content_tag :b, 'Specs:'} #{specs}".html_safe, class: 'specs highlight') if specs.present?)
    end if good_desc.present?)
  end
  
end
