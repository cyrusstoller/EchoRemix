require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "should return a title with no bar" do
    assert_equal "EchoRemix", title
  end

  test "should return a title with a bar" do
    @title = "Hello"
    assert_equal "EchoRemix | Hello", title
  end

  # Logo class tests

  test "should only return the base css class" do
    assert_equal "title-logo", logo_class
  end

  test "should return two css classes for the logo" do
    @logo_class = "small"
    assert_equal "title-logo small", logo_class
  end

  # Alert type

  test "should return 'alert' when given 'error'" do
    assert_equal "alert", alert_type('error')
    assert_equal "alert", alert_type(:error)
  end

  test "should return 'success' when given 'success'" do
    assert_equal "success", alert_type('success')
    assert_equal "success", alert_type(:success)
  end
end
