module ApplicationHelper
  def title
    if @title.blank?
      "EchoRemix"
    else
      "EchoRemix | #{@title}"
    end
  end

  def social_description
    "Anonymous one-on-one conversations about topics that matter."
  end

  def logo_class
    if @logo_class.blank?
      "title-logo"
    else
      "title-logo #{@logo_class}"
    end
  end

  def alert_type(type)
    case type
    when :error, "error"
      "alert"
    when :notice, "notice"
      "warning"
    when :success, "success"
      "success"
    else
      type.to_s
    end
  end
end
