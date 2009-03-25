module ApplicationHelper
  def print_flash(flash, flash_type, title = nil)
    if flash
      title_p = "<h5>#{title}</h5>" if title
      result = "  <div id=\"#{flash_type}-flash\" class=\"flash\">\n    #{title_p}\n    <p>\n"
      
      messages = []
      if flash.class == ActiveRecord::Errors
        flash.each {|attr, msg| messages << "      <span class=\"error-msg\">#{h(msg)}</span>" if !msg.blank?}
      elsif flash.class == Array
        flash.each {|msg| messages << "      <span class=\"error-msg\">#{h(msg)}</span>" if !msg.blank?}
      else
        result << "      <span class=\"error-msg\">#{h(flash)}</span>"
      end
      
      result << messages.join("<br />\n")
      result << "</p>\n    <p>\n      <a href=\"#\" class=\"hide-flash\">Hide</a>\n    </p>\n  </div>"
    end
  end

  def menu_extra(activemenuitem)
    css =  "  <style type=\"text/css\" media=\"screen\">\n"
    css << "  <!--\n"
    css << "    div#menu ul li a##{activemenuitem}, div#menu ul li a##{activemenuitem}:hover {\n"
    css << "      color: #0f0;\n"
    css << "    }\n"
    css << "  -->\n"
    css << "  </style>\n"
  end

  def menu_side_bar(&block)
    concat("<div class=\"container\">\r\n        <div>")
    concat(capture(&block))
    concat("  </div>\r\n      </div>")
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
      link_to(display || format_date(date), change_date_url(:date_picker => date.to_s(:db), :section => section), :class => 'change-date-link')
    end
  end

  def dateselect(date)
    select_day(date) + select_month(date) + select_year(date)
  end

  def cancel_button
    '<input name="cancel" type="submit" value="Cancel" />'
  end

  def output_stylesheets(*files)
    output = []
    files.each { |file| output << '  ' + stylesheet_link_tag(file) }
    @extra_stylesheets.each { |file| output << '  ' + stylesheet_link_tag(file) } if @extra_stylesheets
    output.join("\n")
  end

  def output_javascripts(*files)
    output = []
    files.each { |file| output << javascript_include_tag(file) }
    @extra_javascripts.each { |file| output << javascript_include_tag(file) } if @extra_javascripts
    output.join("\n")
  end
end
