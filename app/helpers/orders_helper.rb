module OrdersHelper
  def order_status_helper(order)
    case order.status
    when 'New PO', 'PO Released'
      if order.created_at <= Time.now - 2.days
        display = "Still unaccepted by #{order.seller.nickname}?<br> Age: #{time_ago_in_words(order.created_at)}".html_safe
        color = "label-warning"
      else
        display = order.status
      end
    when 'For-Delivery'
      if order.confirmed >= Date.today - 3.days
        display = order.status
      elsif order.confirmed >= Date.today - 5.days
        display = "Age: #{time_ago_in_words(order.confirmed)}"
        color = "label-warning"
      else
        display = "Not delivered?<br> Age: #{time_ago_in_words(order.confirmed)}".html_safe
        color = "label-important"
      end
    when 'Delivered'
      if order.due_date > Date.today + 5.days
        display = "Due In: #{pluralize order.days_underdue, 'day'}"
        color = "label-success"
      elsif order.due_date > Date.today 
        display = "Due In: #{pluralize order.days_underdue, 'day'}"
        color = "label-warning"
      elsif order.due_date == Date.today 
        display = "Due Today!"
        color = "label-notice"
      else
        display = "Overdue: #{pluralize order.days_overdue, 'day'}"
        color = "label-important"
      end
    else
      display = order.status
      color = order.status_color
    end
    
    content_tag :p, display, class: "label center #{color}"
  end
  
  def payment_tag(order)
    if order.was_fulfilled
      if order.paid && order.paid_but_overdue
        if order.paid_but_overdue > 0
          content_tag :span, "Overdue: #{pluralize order.paid_but_overdue, 'day'}", class: 'payment-tag label label-important'
        else
          content_tag :span, "Paid on time!", class: 'payment-tag label label-success'
        end
      end
    end
  end
  
  def change_status_link(order)
    tag = case order.status
    when 'For-Delivery' then 'Delivered'
    when 'Delivered' #then 'Paid'
      if can? :create, :orders
        'Paid.' # buyer's tagging only ... for subsequent confirmation by seller
      else
        'Paid'
      end
    else nil
    end  
    link_to("#{content_tag :i, '', class: 'icon-tag '} Tag as #{tag}".html_safe, change_status_order_path(order, cs: tag.html_safe), confirm: 'Are you sure?', class: 'btn small') if tag
  end
  
  def confirm_payment_link(order, user)
    if order.paid_temp && order.paid.nil?
      if order.seller_id == user.id
        link_to("#{content_tag :i, '', class: 'icon-check icon-white'} Confirm Payment".html_safe, change_status_order_path(order, cs: 'Paid'), confirm: 'Are you sure?', class: 'btn small btn-info')
      else
        content_tag :span, "awaiting seller's confirmation", class: 'label label-info'
      end
    end
  end
  
  def link_to_entry_helper(entry)
    if can? :access, :all
		  link_with_icon "Review Entry/Photos", @entry, 'folder-open', 'btn-info', true 
		elsif can? :create, :entries                                                       
		  link_with_icon "Review Entry/Photos", buyer_show_path(@entry), 'folder-open', 'btn-info', true 
		else                                                                             
		  link_with_icon "Review Entry/Photos", seller_show_path(@entry), 'folder-open', 'btn-info', true 
		end
  end
  
  def link_to_accept(order)
    link_to "Accept Order", accept_order_path(order), rel: 'popover', data: { content: 'Accept the order to confirm.', "original-title" => 'Can you deliver?'}, class: 'accept btn btn-success floatright'		
  end
end
