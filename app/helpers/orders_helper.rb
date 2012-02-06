module OrdersHelper
  def overdue_tag(order)
    if order.is_not_yet_paid && Date.today > order.due_date
      content_tag :span, "Overdue: #{pluralize order.days_overdue, 'day'}", class: 'label important'
    elsif order.paid && order.paid_but_overdue
      if order.paid_but_overdue > 0
        content_tag :span, "Overdue: #{pluralize order.paid_but_overdue, 'day'}", class: 'label important'
      else
        content_tag :span, "Paid before due date!", class: 'label success'
      end
    end
  end
  
  def payment_tag(order)
    if order.was_fulfilled
      if order.is_not_yet_paid 
        if Date.today > order.due_date
          content_tag :span, "Overdue: #{pluralize order.days_overdue, 'day'}", class: 'label important'
        else
          content_tag :span, "Due Date: #{pluralize order.days_underdue, 'day'}", class: 'label important'
        end
      elsif order.paid && order.paid_but_overdue
        if order.paid_but_overdue > 0
          content_tag :span, "Overdue: #{pluralize order.paid_but_overdue, 'day'}", class: 'label important'
        else
          content_tag :span, "Paid before due date!", class: 'label success'
        end
      end
      
    end
    
    # content_tag :p, 
  end
  
  def change_status_link(order)
    tag = case order.status
    when 'For-Delivery' then 'Delivered'
    when 'Delivered' then 'Paid'
    else nil
    end  
    link_to("Tag as #{tag}", change_status_order_path(order, cs: tag), class: 'btn small') if tag
  end
  
end
