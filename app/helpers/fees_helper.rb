module FeesHelper
  def period_covered_helper(search_query=nil)
    if search_query.present? && search_query[:created_at_gteq].present?
      "(#{regular_date(search_query[:created_at_gteq].to_date)} - #{regular_date(search_query[:created_at_lteq].to_date)})"
    elsif search_query.present? && search_query[:created_at_gteq].blank?
      ""
    else
      "(#{regular_date(Date.today.beginning_of_month)} - #{regular_date(Date.today)})"
    end
  end
  
end
