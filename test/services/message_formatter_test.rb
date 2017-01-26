require 'test_helper'

class MessageFormatterTest < ActiveSupport::TestCase
  test "it should return the string as is when there are no links" do
    str = "Hello world"
    m = MessageFormatter.new(str)
    assert_equal str, m.markup
  end

  test "it should escape the HTML" do
    str = "Hi & co"
    escaped_str = "Hi &amp; co"
    m = MessageFormatter.new(str)
    assert_equal escaped_str, m.markup
  end

  test "it should identify url with http in the beginning" do
    str = "http://example.com"
    output = '<a href="http://example.com" target=\'_window\'>http://example.com</a>'
    m = MessageFormatter.new(str)
    assert_equal output, m.markup
  end

  test "it should identify url with www in the beginning" do
    str = "www.example.com"
    output = '<a href="http://www.example.com" target=\'_window\'>www.example.com</a>'
    m = MessageFormatter.new(str)
    assert_equal output, m.markup
  end

  test "it should not render a script tag" do
    str = "hello world <script>alert()</script>"
    m = MessageFormatter.new(str)
    assert_not_equal str, m.markup
    assert_no_match /<script/, m.markup
  end

  test "it should be html_safe" do
    str = "hello world"
    m = MessageFormatter.new(str)
    assert m.markup.html_safe?
  end
end
