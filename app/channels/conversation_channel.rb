# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ConversationChannel < ApplicationCable::Channel
  def subscribed
    stream_from user_id
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    disconnect_from_conversation

    # Make sure that this user isn't matched with anyone else
    Matcher.remove(user_id)
  end

  def message(data)
    message = data['message']
    Conversation.broadcast_from_user(user_id, nickname, message)
  end

  def typing
    Conversation.broadcast_typing_from_user(user_id, nickname)
  end

  # Also called when the user first lands on the chat page
  def egress(data)
    disconnect_from_conversation

    if data['get_next'] and not nickname.blank?
      Matcher.create_chat(user_id)
    end
  end

  private

    def disconnect_from_conversation
      other_user_ids = Matcher.conversation_ended_by_user(user_id)
      other_user_ids.each do |u_id|
        # Put the other users into the waiting pool
        Matcher.create_chat(u_id)
      end
    end

    # FILTER out the message so that it is not stored in the logs

    def transmit(data, via: nil) # :doc:
      transmitted_data = data.dup
      unless transmitted_data["message"].nil?
        transmitted_data["message"] = "[FILTERED]"
      end

      logger.info "#{self.class.name} transmitting #{transmitted_data.inspect.truncate(300)}".tap { |m| m << " (via #{via})" if via }

      payload = { channel_class: self.class.name, data: data, via: via }
      ActiveSupport::Notifications.instrument("transmit.action_cable", payload) do
        connection.transmit identifier: @identifier, message: data
      end
    end

    def action_signature(action, data)
      "#{self.class.name}##{action}".tap do |signature|
        if (arguments = data.except("action")).any?
          arguments["message"] = "[FILTERED]"
          signature << "(#{arguments.inspect})"
        end
      end
    end
end
