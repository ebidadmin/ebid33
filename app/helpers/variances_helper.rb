module VariancesHelper
  def var_title
    "For accurate computation"
  end
  
  def var_tooltip
    "Give #{content_tag :span, 'FULL Price', class: 'highlight'}, NOT the discounted price. 
    Don't forget the #{content_tag :span, 'correct QUANTITY', class: 'highlight'} also.".html_safe
  end
end
