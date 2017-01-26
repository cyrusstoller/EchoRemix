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
    end

    REDIS.sadd(WAITING_POOL, prev_partners) unless prev_partners.empty?
  end

  def self.remove(user_id)
    REDIS.srem(WAITING_POOL, user_id)
  end

  def self.remove_all
    REDIS.del(WAITING_POOL)
  end
end
