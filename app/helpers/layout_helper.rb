# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def title(page_title, show_title = true)
    content_for(:title) { h(page_title.to_s) }
    @show_title = show_title
  end
  
  def subtitle(subtitle)
    content_for(:subtitle) { (content_tag :small, subtitle).html_safe }
  end

  def show_title?
    @show_title
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end
  
  def nav_link(text, page, *args) 
    content_tag :li, (link_to text, page, *args), class: current?(page)
  end 

  def current?(page_name)
    "active" if current_page? page_name
  end
  
  def drop_link(text)
    link_to("#{text} #{content_tag :b, '', class: 'caret'}".html_safe, '#', class: "dropdown-toggle", "data-toggle" => "dropdown")
  end

  def drop_active?(action)
    "active" if params[:action] == action
  end
  
  def drop_active_cont?(controller)
    "active" if params[:controller] == controller
  end

  def link_with_icon(name, page, icon_name, klass=nil, white=false, print=false)
    icon = content_tag(:i, '', class: "icon-#{icon_name}#{' icon-white' if white == true}")
    if print == true
  		link_to (icon + ' ' + name), page, class: "btn #{klass}", onclick: "window.print(); return false" 
    else
      link_to (icon + ' ' + name), page, class: "btn #{klass}"
    end
  end
  
end
