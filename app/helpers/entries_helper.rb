module EntriesHelper
  def bidding_session_time_helper(entry)
    if entry.is_online && Time.now < entry.bid_until
      dl_helper 'Bidding Deadline', long_date(entry.bid_until)
    end
  end
  
  def number_of_bidders(entry)
    count = entry.unique_bidders
    if count > 0
      "#{pluralize count, 'bidder'}<br> for 
      #{pluralize entry.items_bidded, 'item'}".html_safe
    else
      "Sorry, no bidders."
    end
  end
  
  def fastest_bid(entry)
    "Fastest: #{time_in_words entry.bids.minimum(:bid_speed)}"
  end
  
end
