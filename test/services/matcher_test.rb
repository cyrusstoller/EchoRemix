require 'test_helper'

class MatcherTest < ActiveSupport::TestCase
  WAITING_POOL = Matcher::WAITING_POOL

  def pool
    REDIS.smembers WAITING_POOL
  end

  def pool_size
    REDIS.scard WAITING_POOL
  end

  teardown do
    REDIS.flushdb
  end

  # Single user
  test "should add a new user to the WAITING_POOL" do
    user_id = "user1"
    Matcher.create_chat(user_id)

    assert_includes pool, user_id
    assert_equal 1, pool_size
  end

  test "remove a user from the WAITING_POOL" do
    user_id = "user1"
    REDIS.sadd WAITING_POOL, user_id

    Matcher.remove user_id
    assert_equal 0, pool_size
  end

  # Two users - have not talked

  test "should create a conversation" do
    user1 = "user1"
    user2 = "user2"
    Matcher.create_chat(user1)
    Matcher.create_chat(user2)
    assert_equal 0, pool_size
  end

  # Two users - have talked previously

  test "should not create a conversation" do
    user1 = "user1"
    user2 = "user2"
    REDIS.sadd "#{user1}:recent", user2
    REDIS.sadd "#{user2}:recent", user1

    Matcher.create_chat(user1)
    Matcher.create_chat(user2)

    assert_equal 2, pool_size
  end

  # Three users

  test "should create the conversation between two users who have not talked" do
    user1 = "user1"
    user2 = "user2"
    user3 = "user3"
    REDIS.sadd "#{user1}:recent", user2
    REDIS.sadd "#{user2}:recent", user1

    Matcher.create_chat(user1)
    Matcher.create_chat(user2)
    Matcher.create_chat(user3)

    assert_not_includes pool, user3
    assert_equal 1, pool_size
  end

  test "should create the conversation between the two new users to each other" do
    user1 = "user1"
    user2 = "user2"
    user3 = "user3"
    REDIS.sadd "#{user1}:recent", [user2, user3]
    REDIS.sadd "#{user2}:recent", [user1]
    REDIS.sadd "#{user3}:recent", [user1, "user4"]

    REDIS.sadd WAITING_POOL, [user1, user3]

    assert_equal 2, pool_size

    Matcher.create_chat(user2)

    assert_includes pool, user1
    assert_not_includes pool, user2
    assert_not_includes pool, user3
    assert_equal 1, pool_size
  end

  # Clearing the waiting pool

  test "clear the waiting pool" do
    REDIS.sadd WAITING_POOL, ["user1", "user2"]
    Matcher.remove_all

    assert_equal 0, pool_size
  end
end
