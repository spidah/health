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
    css << "ul#nav li a##{activemenuitem}, ul#nav li a##{activemenuitem}:hover {\n"
    css << "  background: #fff;\n"
    css << "  color: #003;\n"
    css << "}\n"
    css << "-->\n"
    css << "</style>\n"
  end

  def menu_side_bar(&block)
    content = capture(&block)
    concat("<div class=\"container\">\r\n\t\t\t\t<div>\r\n\t\t\t\t", block.binding)
    concat(content, block.binding)
    concat("\t</div>\r\n\t\t\t</div>", block.binding)
  end
  
  def format_date(date, format = nil)
    date.strftime(format || '%d %B %Y')
  end

  def format_fixed_number(number)
    (number / 100).to_s
  end

  def link_date(date)
    link_to(format_date(date), change_date_path(:date_picker => date.to_s(:db)), :class => 'change-date-link')
  end

  def dateselect(date)
    select_day(date) + select_month(date) + select_year(date)
  end
end
