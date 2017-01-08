require 'test_helper'

class ChatControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to the root if there is no nickname" do
    get chat_url
    assert_redirected_to root_url
  end

  def create_a_nickname(nickname)
    post chat_url, params: { nickname: nickname }
  end

  test "should create a chat signed cookie" do
    nickname = "cyro"
    create_a_nickname nickname
    assert_redirected_to chat_url
    assert_equal nickname, request.cookie_jar.signed['nickname']
  end

  test "should stay on the chat page if there is a nickname" do
    create_a_nickname "cyrus"
    get chat_url
    assert_response :success
  end

  test "should redirect back to the root_url if they try to call themselves root" do
    create_a_nickname "system"
    assert_redirected_to root_url
  end
end
