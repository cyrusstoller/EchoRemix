require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  test "should not be valid without text" do
    topic = topics(:one)
    topic.text = ""
    assert_not topic.valid?
  end

  test "should not be valid if the text is non-unique" do
    topic = topics(:one).dup
    assert_not topic.valid?
  end

  test "should not be valid without weight" do
    topic = topics(:one)
    topic.weight = nil
    assert_not topic.valid?
  end

  # random text

  test "should provide random text when there are Topics" do
    assert_includes %w(MyString1 MyString2), Topic.random
  end

  test "should provide for the other text when one is excluded" do
    assert_equal "MyString1", Topic.random("MyString2")
  end

  test "should not throw an error when there are no Topics" do
    Topic.destroy_all
    assert_match /waiting/i, Topic.random
  end
end
