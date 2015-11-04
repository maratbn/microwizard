module ApplicationHelper
  MAX_PAGES = 15

  def break_long_words(str, len = 30)
    safe_join(str.split(" ").map{|w|
      if w.length > len
        safe_join(w.split(/(.{#{len}})/), "<wbr>".html_safe)
      else
        w
      end
    }, " ")
  end

  def errors_for(object, message=nil)
    html = ""
    unless object.errors.blank?
      html << "<div class=\"flash-error\">\n"
      object.errors.full_messages.each do |error|
        html << error << "<br>"
      end
      html << "</div>\n"
    end

    raw(html)
  end

  def page_numbers_for_pagination(max, cur)
    if max <= MAX_PAGES
      return (1 .. max).to_a
    end

    pages = (cur - (MAX_PAGES / 2) + 1 .. cur + (MAX_PAGES / 2) - 1).to_a

    while pages[0] < 1
      pages.push (pages.last + 1)
      pages.shift
    end

    while pages.last > max
      if pages[0] > 1
        pages.unshift (pages[0] - 1)
      end
      pages.pop
    end

    if pages[0] != 1
      if pages[0] != 2
        pages.unshift "..."
      end
      pages.unshift 1
    end

    if pages.last != max
      if pages.last != max - 1
        pages.push "..."
      end
      pages.push max
    end

    pages
  end

  def time_ago_in_words_label(time, options = {})
    strip_about = options.delete(:strip_about)
    ago = time_ago_in_words(time, options)

    if strip_about
      ago.gsub!(/^about /, "")
    end

    raw(label_tag(nil, "#{ago} ago", :title => time.strftime("%F %T %z")))
  end
end
