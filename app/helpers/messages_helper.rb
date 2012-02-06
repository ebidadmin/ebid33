module MessagesHelper
  def nested_messages(messages, klass=nil)
   messages.map do |m, sub_messages|
        (render 'messages/msg_line', m: m, k: klass) + (nested_messages(sub_messages, 'nested' ) if sub_messages.present?)
    end.join.html_safe
  end
  
  def message_label_and_field(f, msg_for, open_tag)
    case open_tag
    when 'false'
      f.input :message, label: "Private Message for #{msg_for.to_s.upcase}", input_html: { rows: 2, class: 'span12' }
    when 'edit'
      f.input :message, label: "Edit Message", input_html: { rows: 2, class: 'span12' }
    else
      f.input :message, label: "PUBLIC MESSAGE (note: this will be seen by everyone)", input_html: { rows: 2, class: 'span12' }
    end
  end
  
  def user_signature(message, current_user)
    # if message.user == current_user
    #   content_tag :span, 'YOU said', class: 'label notice'
    # else
    #   "#{message.user_type.titleize} ##{message.user_id} said:"
    # end
    sender = case message.user
    when current_user then content_tag :span, 'YOU said', class: 'label notice'
    else "#{message.user_type.titleize} ##{message.user_id} said"
    end
    
    reciever = case message.reciever
    when nil then nil
    when current_user then content_tag :span, 'to YOU', class: 'label'
    else "<br> to #{message.reciever.roles.first.name}"
    end
    
    "#{sender} #{reciever if reciever.present?}".html_safe
  end
  
  def message_buttons(msg_type, entry, order)
    if msg_type == 'Private'
      btns = button_for('Admin', entry, order) + button_for('Buyer', entry, order) + (button_for('Seller', entry, order) if order.present?)
      btns.html_safe + (content_tag :b, 'Send Private Message for ...', class: 'small')
    else
    	link_to('Send Public Message', show_fields_messages_path(msg_for: "public", open_tag: true, entry: entry, order: order), class: 'btn small', remote: true) 
    end
  end
  
  def button_for(recipient, entry, order=nil)
  	link_to("#{recipient}", show_fields_messages_path(msg_for: "#{recipient.downcase}", open_tag: false, entry: entry, order: order), class: 'btn small', remote: true) 
  end
  
  
end
