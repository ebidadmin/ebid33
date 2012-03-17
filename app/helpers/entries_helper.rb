module EntriesHelper
  
  def entry_username_helper(entry)
    if entry.user == current_user
      content_tag :span, 'Yours', class: 'label'
    else
      content_tag :em, entry.user.username, class: 'small'
    end
  end
  def bidding_session_time_helper(entry, klass=nil)
    if entry.is_online 
      if Time.now < entry.bid_until
        dl_helper 'Bidding Deadline', long_date(entry.bid_until), klass
      else
        dl_helper 'Bidding Session Ended', long_date(entry.bid_until), klass
      end
    end
  end
  
  def number_of_bidders(entry)
    if entry.newly_created?
      content_tag :span, "Entry is still offline.", class: 'muted'
    else
      count = entry.unique_bidders
      if count > 0
        "#{content_tag :b, (pluralize count, 'bidder')}   
        #{content_tag :em, ' for ' + (pluralize entry.items_bidded, 'item'), class: 'small'}".html_safe
      else
        content_tag :span, "Sorry, no bidders.", class: 'muted'
      end
    end
  end
  
  def fastest_bid(entry)
    "Speed: #{time_in_words entry.bids.minimum(:bid_speed)}"
  end
  
  def entry_status_helper(entry, klass=nil)
    content_tag :p, class: "label #{entry.status_color} #{klass}" do
      "#{entry.show_status}#{'<br> (with cancellation)' if !entry.is_online && entry.bids.cancelled.present? }".html_safe
    end
  end
  
  def order_now_helper(entry)
    if (entry.status == "For-Decision" || entry.status == "Ordered-IP" || entry.status == "Declined-IP") && entry.expired.nil?
      deadline = entry.bid_until + 3.days
      if Time.now < deadline 
        content_tag(:span, "Order Now!", class: 'label label-important') +
        content_tag(:p, "Expiry: #{time_ago_in_words(deadline)}")
      elsif Time.now == deadline
        content_tag(:span, "Order Now!", class: 'label label-important') +
        content_tag(:p, "Expiring Today")
      elsif Time.now > deadline
        content_tag(:span, "Lapsed", class: 'label') +
        content_tag(:p, regular_date(deadline), class: 'muted')
      end
    end
  end
  
end
