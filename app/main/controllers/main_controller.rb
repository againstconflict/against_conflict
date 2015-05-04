# By default Volt generates this controller for your Main component
class MainController < Volt::ModelController
  model :store
 
  def index
  end
 
  def send_message
    unless page._new_message.strip.empty?
      _messages << { sender_id: Volt.user._id, receiver_id: params._user_id, text: page._new_message }
      _notifications << { sender_id: Volt.user._id, receiver_id: params._user_id }
      page._new_message = ''
    end
  end
 
  def current_conversation
    _messages.find({ "$or" => [{ sender_id: Volt.user._id, receiver_id: params._user_id }, { sender_id: params._user_id, receiver_id: Volt.user._id }] })
  end
 
  def select_conversation(user)
    params._user_id = user._id
    unread_notifications_from(user).then do |results|
      results.each do |notification|
        _notifications.delete(notification)
      end
    end
    page._new_message = ''
    unless Volt.user._is_speaker == false
      Volt.user._is_speaker = true
      user._is_speaker = false
    end
  end

  def i_feel_understood(user)
    Volt.user._is_speaker = false
    user._is_speaker = true
    _messages << { sender_id: Volt.user._id, receiver_id: params._user_id, text: "I feel you understand me! Please now share your point of view and I will listen." }
  end

  def go_ahead(user)
    user._go_ahead = true
    _messages << { sender_id: Volt.user._id, receiver_id: params._user_id, text: "Please go ahead." }
  end
  
  def not_quite(user)
    user._go_ahead = false
    _messages << { sender_id: Volt.user._id, receiver_id: params._user_id, text: 'Not quite, let me elaborate.' }
  end

  def i_think_i_understand(user)
    _messages << { sender_id: Volt.user._id, receiver_id: params._user_id, text: 'I think I understand.' }
  end

  def unread_notifications_from(user)
    _notifications.find({ sender_id: user._id, receiver_id: Volt.user._id })
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