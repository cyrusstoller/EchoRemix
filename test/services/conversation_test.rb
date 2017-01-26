require 'test_helper'

class ConversationTest < ActiveSupport::TestCase
  teardown do
    REDIS.flushdb
  end

  def create_conversation(*user_ids)
    user_ids.each do |u|
      REDIS.set "#{u}:nickname", "#{u}-nickname"
    end

    c = Conversation.new(*user_ids)
    c.create
  end

  # Instance

  test "creating a conversation" do
    user1 = "user1"
    user2 = "user2"
    c_id = create_conversation(user1, user2)
    conversation = REDIS.smembers c_id

    # Check that the user_ids are in the conversation
    assert_equal 2, (REDIS.scard c_id)
    assert_includes conversation, user1
    assert_includes conversation, user2

    # Check that the user_ids point to the conversation
    assert_equal c_id, (REDIS.get user1)
    assert_equal c_id, (REDIS.get user2)
  end

  # Class

  test "broadcast a message from a user" do
    user1 = "user1"
    user2 = "user2"
    c_id = create_conversation(user1, user2)

    assert_nothing_raised {
      Conversation.broadcast_from_user(user1, "nickname", "hi there!")
    }
  end

  test "broadcast typing from a user" do
    user1 = "user1"
    user2 = "user2"
    c_id = create_conversation(user1, user2)

    assert_nothing_raised {
      Conversation.broadcast_typing_from_user(user1, "nickname")
    }
  end

  test "broadcast a new topic" do
    user1 = "user1"
    user2 = "user2"
    c_id = create_conversation(user1, user2)

    assert_nothing_raised {
      Conversation.broadcast_next_topic(user1, "nickname", "hi")
    }
  end

  test "broadcast that a conversation has been ended by a user" do
    user1 = "user1"
    user2 = "user2"
    c_id = create_conversation(user1, user2)

    remaining_users = Conversation.ended_by_user(user1)
    assert_includes remaining_users, user2

    # Destroys the conversation
    assert_empty (REDIS.smembers c_id)
    assert_nil (REDIS.get user1)
    assert_nil (REDIS.get user2)

    # Sets up records to prevent rematching
    assert_includes (REDIS.smembers "#{user1}:recent"), user2
    assert_includes (REDIS.smembers "#{user2}:recent"), user1
  end
end
