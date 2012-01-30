module MessagesHelper
  def nested_messages(messages, klass=nil)
    # messages.map do |m, sub_messages|
    #   content_tag :li, (render 'msg_line', :m => m) + (content_tag :ul, nested_messages(sub_messages), :class => 'unstyled nested' if sub_messages.present?), class: 'level'
    # end.join.html_safe
    messages.map do |m, sub_messages|
        (render 'msg_line', :m => m, :k => klass) + (nested_messages(sub_messages, 'nested' ) if sub_messages.present?)
    end.join.html_safe
  end
  
end
