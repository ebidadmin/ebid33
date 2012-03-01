module ApplicationHelper
  def dl_helper(tag, item, klass=nil)
    (content_tag :dt, tag, class: "#{klass}") + (content_tag :dd, item.html_safe, class: "#{klass}")
  end
  
  def time_in_words(time)
    distance_in_hours   = ((time.abs) / 3600).round
    distance_in_minutes = (((time.abs) % 3600) / 60).round

    difference_in_words = ''

    difference_in_words << "#{distance_in_hours}hr " if distance_in_hours > 0
    difference_in_words << "#{distance_in_minutes}min"
  end
  
  def long_date(date)
    date.strftime('%d %b %Y, %a %R')
  end
  
  def short_date(date)
    date.strftime("%d %b '%y, %R")
  end
  
  def regular_date(date, requirement=nil)
    case requirement
    when 'long' then date.strftime('%d %b %Y')
    when 'day' then date.strftime("%d %b %Y, %a")
    else date.strftime("%d %b %Y")
    end
  end

  def ph_currency(target)
    if target > 0 || target < 0
      number_to_currency target, :unit => 'P '
    else
      '-'
    end
  end

  def currency(target)
    if target > 0 || target < 0
      number_to_currency target, :unit => ''
    else
      '-'
    end
  end

  def shorten(target, size)
    truncate(target, length: size, separator: ' ')
  end

  def percentage(target)
    if target > 0
      number_to_percentage target, :precision => 2
    else
      nil
    end
  end
  
  def percentage3(target)
    if target && target > 0
      number_to_percentage target, :precision => 3
    elsif target.blank?
      ''
    else
      'FREE'
    end
  end
  
  # for Orders and Fees
  def display_seller_company
    content_tag :span, @seller_company.nickname, class: 'label label-info' if @seller_company
  end
  
  def display_buyer_company
    content_tag :span, @buyer_company.nickname, class: 'label label-info' if @buyer_company
  end
end
