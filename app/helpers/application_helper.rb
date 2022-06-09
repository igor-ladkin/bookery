module ApplicationHelper
  def error_tag(record, attribute)
    if record.errors[attribute].any?
      content_tag :p, record.errors[attribute].first, class: "help is-danger"
    end
  end
end
