module ApplicationHelper
  def dl_helper(tag, item, klass=nil)
    (content_tag :dt, tag, class: "span2") + (content_tag :dd, item)
  end
  
  def time_in_words(time)
    distance_in_hours   = ((time.abs) / 3600).round
    distance_in_minutes = (((time.abs) % 3600) / 60).round

    difference_in_words = ''

    difference_in_words << "#{distance_in_hours}h " if distance_in_hours > 0
    difference_in_words << "#{distance_in_minutes}m"
  end
  
  def long_date(date)
    date.strftime('%d-%b-%Y, %a %R')
  end
  
  def short_date(date)
    date.strftime('%d-%b-%y, %R')
  end
  
  def regular_date(date, digits=nil)
    digits.present? ? date.strftime("%d %b '%y") : date.strftime('%d %b %Y')
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

end
