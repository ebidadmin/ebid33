module FeesHelper
  def period_covered_helper(fees, search_query=nil)
    if search_query.present? && search_query[:created_at_gteq].present? && search_query[:created_at_lteq].blank?
      "(#{regular_date(search_query[:created_at_gteq].to_date)} - #{regular_date(Date.today)})"
    elsif search_query.present? && search_query[:created_at_gteq].present?
      "(#{regular_date(search_query[:created_at_gteq].to_date)} - #{regular_date(search_query[:created_at_lteq].to_date)})"
    elsif search_query.present? && search_query[:created_at_gteq].blank? && fees.present?
      "#{regular_date(fees.last.created_at)} - #{regular_date(Date.today)}" 
    else
      "(#{regular_date(Date.today.beginning_of_month)} - #{regular_date(Date.today)})"
    end
  end
  
  def entry_link(entry)
    if can? :access, :all then link = entry
    elsif can? :create, :entries then link = buyer_show_path(entry)
    elsif can? :access, :bids then link = seller_show_path(entry)
    end
    link_to entry.model_name, link
  end
  
  def total_row(rowlabel, col1total, col2total=nil)
    content_tag :tr, class: 'total' do 
      (content_tag :td) +
      (content_tag :td do 
        content_tag(:div, '', class: 'part span3') + 
        content_tag(:div, rowlabel, class: 'amount txtright') +
        content_tag(:div, '', class: 'factors') +
        content_tag(:div, '', class: 'factors') +
        content_tag(:div, col1total, class: 'amount txtright') +
        content_tag(:div, col2total, class: 'amount txtright')
      end) 
    end 
  end
  
  def print_type(params)
    if params
      params
    elsif can? :create, :entries # buyers
      'bf'
    elsif can? :create, :bids # sellers
      'sf'
    end
  end
end
