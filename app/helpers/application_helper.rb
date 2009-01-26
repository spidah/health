module ApplicationHelper
  def print_flash(flash, flash_type, title = nil)
    if flash
      hide_link = link_to_function 'Hide' do |page| page["#{flash_type}-flash"].visual_effect :fade end
      title_p = "<h5>#{title}</h5>" if title
      result = "<div class=\"#{flash_type}\" id=\"#{flash_type}-flash\">#{title_p}<p>"

      if flash.class == ActiveRecord::Errors
        messages = []
        flash.each {|attr, msg| messages << "<span class=\"error-msg\">#{h(msg)}</span>" if !msg.blank?}
        result << messages.join('<br />')
      elsif flash.class == Array
        messages = []
        flash.each {|msg| messages << "<span class=\"error-msg\">#{h(msg)}</span>" if !msg.blank?}
        result << messages.join('<br />')
      else
        result << "<span class=\"error-msg\">#{h(flash)}</span>"
      end

      result << "</p><p>#{hide_link}</p></div>"
    end
  end

  def menu_extra(activemenuitem)
    css = "<style type=\"text/css\" media=\"screen\">\n"
    css << "<!--\n"
    css << "div#menu ul li a##{activemenuitem}, div#menu ul li a##{activemenuitem}:hover {\n"
    css << "  color: #0f0;\n"
    css << "}\n"
    css << "-->\n"
    css << "</style>\n"
  end

  def menu_side_bar(&block)
    content = capture(&block)
    concat("<div class=\"container\">\r\n\t\t\t\t<div>\r\n\t\t\t\t")
    concat(content)
    concat("\t</div>\r\n\t\t\t</div>")
  end
  
  def format_date(date, format = nil, current = nil)
    if current && current == date
      'today'
    else
      date.strftime(format || '%d %B %Y')
    end
  end

  def format_fixed_number(number)
    (number / 100).to_s
  end

  def link_date(date, section = 'dashboard', display = nil, today = nil)
    if today && date > today
      display || format_date(date)
    else
      link_to(display || format_date(date), change_date_path(:date_picker => date.to_s(:db), :section => section), :class => 'change-date-link')
    end
  end

  def dateselect(date)
    select_day(date) + select_month(date) + select_year(date)
  end

  def cancel_button
    '<input name="cancel" type="button" value="Cancel" onclick="history.go(-1)" />'
  end
end
