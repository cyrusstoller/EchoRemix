class Conversation
  def initialize(*user_ids)
    @user_ids = user_ids
  end

  def create
    @c_id = "conversation_" + SecureRandom.uuid
    topic = Topic.random

    REDIS.sadd @c_id, @user_ids

    # set the user_id values to the c_id
    @user_ids.each do |u_id|
      REDIS.set u_id, @c_id
      send_match(u_id, @user_ids, topic)
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
        broadcast_to_user(u_id, { nickname: nickname, typing: true })
      end
    end
  end

  def self.broadcast_next_topic(user_id, nickname, current_topic)
    c_id = REDIS.get user_id
    topic = Topic.random(current_topic)
    msg = "#{nickname} has requested a new topic. Your next topic: #{topic}"
    broadcast(c_id, "System", message: msg, topic: topic)
  end

  def self.ended_by_user(user_id)
    c_id = REDIS.get user_id
    user_ids = REDIS.smembers c_id

    user_ids.each do |u_id|
      REDIS.del u_id
      REDIS.sadd "#{u_id}:recent", user_ids
      REDIS.expire "#{u_id}:recent", 15
      broadcast_to_user u_id, { waiting_pool: true }
    end

    REDIS.del c_id

    # Return all of the user_ids except the one that I entered
    user_ids.select { |u_id| u_id != user_id }
  end

  private

  # Instance

  def send_match(u_id, user_ids, topic)
    other_user_ids = user_ids.reject { |i| i == u_id }
    other_users = other_user_ids.map { |u| REDIS.get "#{u}:nickname" }.to_sentence

    payload = {
      nickname: "System",
      message: self.class.format_message("System",
        "You've been matched with #{other_users}! Your first topic: #{topic}"),
      topic: topic
    }

    self.class.broadcast_to_user u_id, payload
  end

  # Class

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
      broadcast_to_user(u_id, payload)
    end
  end

  def self.broadcast_to_user(user_id, payload = {})
    ActionCable.server.logger.silence do
      ActionCable.server.broadcast user_id, payload
    end
  end

  def self.format_message(nickname, message)
    messsage_formatter = MessageFormatter.new(message)
    message_with_markup = messsage_formatter.markup

    res = ChatController.render partial: 'message', locals: { nickname: nickname, message: message_with_markup }
    res.squish
  end
end
