# By default Volt generates this controller for your Main component
class MainController < Volt::ModelController
  model :store
 
  def index
  end
 
  def user_index
    render user_index
  end

  def send_message
    unless page._new_message.strip.empty?
      _messages << { sender_id: Volt.user._id, receiver_id: params._user_id, opinion_id: params._opinion_id, text: page._new_message }
      _notifications << { sender_id: Volt.user._id, receiver_id: params._user_id, opinion_id: params._opinion_id }
      page._new_message = ''
    end
  end

  def current_conversation
    _messages.find({ "$or" => [{ sender_id: Volt.user._id, receiver_id: params._user_id, opinion_id: params._opinion_id }, { sender_id: params._user_id, receiver_id: Volt.user._id, opinion_id: params._opinion_id }] })
  end

  def this_conversation
    _conversations.find_one({ "$or" => [{ sender_id: Volt.user._id, receiver_id: params._user_id, opinion_id: params._opinion_id }, { sender_id: params._user_id, receiver_id: Volt.user._id, opinion_id: params._opinion_id }] })
  end

  def add_conversation(user, opinion)
    _conversations << { sender_id: Volt.user._id, receiver_id: user._id, opinion_id: opinion._id, speaker_id: user._id }
    _messages << { sender_id: Volt.user._id, receiver_id: user._id, opinion_id: opinion._id, text: "I want to understand this!" }
    _notifications << { sender_id: Volt.user._id, receiver_id: user._id, opinion_id: opinion._id }
  end
  
  def my_conversations
    _conversations.find({ "$or" => [{ sender_id: Volt.user._id }, { receiver_id: Volt.user._id }] })
  end
 
  def select_conversation(user_id, opinion_id)
    user = _users.find_one( _id: user_id )
    opinion = _opinions.find_one( _id: opinion_id )
    params._user_id = user._id
    params._opinion_id = opinion._id
    unread_notifications_from(user_id, opinion_id).then do |results|
      results.each do |notification|
        _notifications.delete(notification)
      end
    end
    page._new_message = ''
  end

  def scroll_down
    %x{document.getElementById('conversation-scroller').scrollTop = document.getElementById('conversation-scroller').scrollHeight}
    return nil
  end

  def i_feel_understood(conversation, user)
    conversation._speaker_id = user._id
    conversation._go_ahead_user_id = 0
    _messages << { sender_id: Volt.user._id, receiver_id: params._user_id, opinion_id: params._opinion_id, text: "I feel you understand me! Your turn." }
    _notifications << { sender_id: Volt.user._id, receiver_id: user._id, opinion_id: conversation._opinion_id }
  end

  def go_ahead(conversation, user)
    conversation._go_ahead_user_id = user._id
    _messages << { sender_id: Volt.user._id, receiver_id: params._user_id, opinion_id: params._opinion_id, text: "Please go ahead." }
    _notifications << { sender_id: Volt.user._id, receiver_id: user._id, opinion_id: conversation._opinion_id }
  end
  
  def not_quite(conversation, user)
    conversation._go_ahead_user_id = 0
    _messages << { sender_id: Volt.user._id, receiver_id: params._user_id, opinion_id: params._opinion_id, text: 'Not quite, let me explain.' }
    _notifications << { sender_id: Volt.user._id, receiver_id: user._id, opinion_id: conversation._opinion_id }
  end

  def i_think_i_understand(conversation, user)
    _messages << { sender_id: Volt.user._id, receiver_id: params._user_id, opinion_id: params._opinion_id, text: 'I think I understand.' }
    _notifications << { sender_id: Volt.user._id, receiver_id: user._id, opinion_id: conversation._opinion_id }
  end

  def unread_notifications_from(user_id, opinion_id)
    _notifications.find({ sender_id: user_id, receiver_id: Volt.user._id, opinion_id: opinion_id })
  end
 
  
  # opinion stuff
  
  def add_opinion
   _opinions << { user_id: Volt.user._id, name: page._new_opinion }
   page._new_opinion = ''
   unless page._new_opinion.strip.empty?
     _opinions << { user_id: Volt.user._id, name: page._new_opinion }
     page._new_opinion = ''
   end
  end

  def my_opinions
    _opinions.find( user_id: Volt.user._id )
  end

  def other_opinions
   _opinions.find( user_id: { "$ne" => Volt.user._id } )
  end
  
  def remove_opinion(opinion)
    _opinions.delete(opinion)
  end
 
  private
 
  # The main template contains a #template binding that shows another
  # template.  This is the path to that template.  It may change based
  # on the params._controller and params._action values.
  def main_path
    params._controller.or('main') + '/' + params._action.or('index')
  end
 
  # Determine if the current nav component is the active one by looking
  # at the first part of the url against the href attribute.
  def active_tab?
    url.path.split('/')[1] == attrs.href.split('/')[1]
  end
end