require 'test_helper'

class TopicsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @topic = topics(:one)
  end

  def auth_headers
    user = ENV["ADMIN_USER"]
    pw = ENV["ADMIN_PASSWORD"]
    { "HTTP_AUTHORIZATION" => "Basic #{Base64.encode64("#{user}:#{pw}")}" }
  end

  test "should return 401 without headers" do
    get topics_url
    assert_equal 401, status
  end

  test "should get index" do
    get topics_url, headers: auth_headers
    assert_response :success
  end

  test "should get new" do
    get new_topic_url, headers: auth_headers
    assert_response :success
  end

  test "should create topic" do
    assert_difference('Topic.count') do
      post topics_url, params: { topic: { text: @topic.text + "!", weight: @topic.weight } }, headers: auth_headers
    end

    assert_redirected_to topics_url
  end

  test "should show topic" do
    get topic_url(@topic), headers: auth_headers
    assert_response :success
  end

  test "should get edit" do
    get edit_topic_url(@topic), headers: auth_headers
    assert_response :success
  end

  test "should update topic" do
    patch topic_url(@topic), params: { topic: { text: @topic.text, weight: @topic.weight } }, headers: auth_headers
    assert_redirected_to topic_url(@topic)
  end

  test "should destroy topic" do
    assert_difference('Topic.count', -1) do
      delete topic_url(@topic), headers: auth_headers
    end

    assert_redirected_to topics_url
  end
end
