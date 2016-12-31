require 'test_helper'

class StaticControllerTest < ActionDispatch::IntegrationTest
  test "should get welcome" do
    get root_url
    assert_response :success
    assert_select "title", /Welcome/
  end

  test "should get about" do
    get about_url
    assert_response :success
    assert_select "title", /About/
  end

  test "should get community_guidelines" do
    get community_guidelines_url
    assert_response :success
    assert_select "title", /Community Guidelines/
  end

  test "should get faq" do
    get faq_url
    assert_response :success
    assert_select "title", /FAQ/
  end
end
