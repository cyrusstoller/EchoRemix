class Matcher
  WAITING_POOL = "chat_waiting_pool"

  def self.create_chat(user_id)
    partner = REDIS.spop(WAITING_POOL)
    prev_partners = []

    # cycle throught the waiting pool until you find a partner
    while (REDIS.sismember "#{user_id}:recent", partner) || (user_id == partner) do
      prev_partners << partner
      partner = REDIS.spop(WAITING_POOL)
    end

    if partner
      conversation = Conversation.new(user_id, partner)
      conversation.create
    else
      REDIS.sadd(WAITING_POOL, user_id)
      unless prev_partners.empty?
        REDIS.sadd(WAITING_POOL, prev_partners)
      end
    end
  end

  def self.remove(uuid)
    REDIS.srem(WAITING_POOL, uuid)
  end

  def self.remove_all
    REDIS.del(WAITING_POOL)
  end

  def self.conversation_ended_by_user(user_id)
    c_id = REDIS.get user_id
    user_ids = REDIS.smembers c_id

    user_ids.each do |u_id|
      REDIS.del u_id
      REDIS.sadd "#{u_id}:recent", user_ids
      REDIS.expire "#{u_id}:recent", 15
      put_in_waiting(u_id)
    end

    REDIS.del c_id

    # Return all of the user_ids except the one that I entered
    user_ids.select { |u_id| u_id != user_id }
  end

  def self.put_in_waiting(user_id)
    ActionCable.server.logger.silence do
      ActionCable.server.broadcast user_id, { waiting_pool: true }
    end
  end
end
