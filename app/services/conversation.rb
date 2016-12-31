class Conversation
  def initialize(*user_ids)
    @user_ids = user_ids
  end

  def create
    @c_id = "conversation_" + SecureRandom.uuid

    REDIS.sadd @c_id, @user_ids

    # set the user_id values to the c_id
    @user_ids.each do |u_id|
      REDIS.set u_id, @c_id
    end

    self.class.broadcast(@c_id, "System", message: "You've been matched!", topic: Topic.random)
  end

  def self.broadcast(conversation_id, nickname, opts = {})
    user_ids = REDIS.smembers conversation_id
    payload = { nickname: nickname }

    if opts[:message]
      payload[:message] = format_message(nickname, opts[:message])
    end

    if opts[:topic]
      payload[:topic] = opts[:topic]
    end

    user_ids.each do |u_id|
      ActionCable.server.logger.silence do
        ActionCable.server.broadcast u_id, payload
      end
    end
  end

  def self.broadcast_from_user(user_id, nickname, message)
    c_id = REDIS.get user_id
    broadcast(c_id, nickname, message: message)
  end

  def self.broadcast_typing_from_user(user_id, nickname)
    c_id = REDIS.get user_id
    user_ids = REDIS.smembers c_id

    user_ids.each do |u_id|
      unless u_id == user_id
        ActionCable.server.logger.silence do
          ActionCable.server.broadcast u_id, { nickname: nickname, typing: true }
        end
      end
    end
  end

  def self.format_message(nickname, message)
    messsage_formatter = MessageFormatter.new(message)
    message_with_markup = messsage_formatter.markup

    res = ChatController.render partial: 'message', locals: { nickname: nickname, message: message_with_markup }
    res.squish
  end
end
