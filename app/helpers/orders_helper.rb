module OrdersHelper
  def overdue_tag(order)
    if order.is_not_yet_paid
      content_tag :span, "Overdue: #{pluralize order.days_overdue, 'day'}", class: 'label important'
    elsif order.paid && order.paid_but_overdue
      if order.paid_but_overdue > 0
        content_tag :span, "Overdue: #{pluralize order.paid_but_overdue, 'day'}", class: 'label important'
      else
        content_tag :span, "Paid before due date!", class: 'label success'
      end
    end
  end
  
end
