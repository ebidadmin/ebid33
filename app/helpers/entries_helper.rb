module EntriesHelper
  
  def bidding_session_time_helper(entry)
    if entry.is_online && Time.now < entry.bid_until
      dl_helper 'Bidding Deadline', long_date(entry.bid_until)
    end
  end
  
  def number_of_bidders(entry)
    if entry.newly_created?
      "Entry is still offline."
    else
      count = entry.unique_bidders
      if count > 0
        "#{content_tag :b, (pluralize count, 'bidder')} -  
        #{content_tag :em, (pluralize entry.items_bidded, 'item'), class: 'small'}".html_safe
      else
        "Sorry, no bidders."
      end
    end
  end
  
  def fastest_bid(entry)
    "Speed: #{time_in_words entry.bids.minimum(:bid_speed)}"
  end
  
end
