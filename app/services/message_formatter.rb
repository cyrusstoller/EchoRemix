require "uri"

class MessageFormatter
  def initialize(text)
    @text = CGI::escapeHTML text
  end

  # in case I want to add markdown parsing
  def markup
    res = Rinku.auto_link @text, :urls, "target='_window'", ["a", "pre", "code", "kbd", "script", "img"]
    res.html_safe
  end
end
