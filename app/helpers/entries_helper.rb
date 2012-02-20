module EntriesHelper
  
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
      "#{entry.show_status}#{'<br> (with cancellation)' if entry.bids.collect(&:status).include?('Cancelled')}".html_safe
    end
  end
  
end
