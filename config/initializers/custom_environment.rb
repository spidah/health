ActiveRecord::Base.colorize_logging = false

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  error_class = "error-field"
  if html_tag =~ /<(input|textarea|select)[^>]+class=/
    class_attribute = html_tag =~ /class=['"]/
    html_tag.insert(class_attribute + 7, "#{error_class}; ")
  elsif html_tag =~ /<(input|textarea|select)/
    first_whitespace = html_tag =~ /\s/
    html_tag[first_whitespace] = " class='#{error_class}' "
  end
  html_tag
end

ActiveRecord::Base.default_timezone = :utc
ENV['TZ'] = 'UTC'

require 'will_paginate'

require 'pp'

# ActionView Text Helpers are great!
# Let's extend the String class to allow us to call
# some of these methods directly on a String.
# Note: 
#  - cycle-related methods are not included
#  - concat is not included
#  - pluralize is not included because it is in 
#       ActiveSupport String extensions already
#       (though they differ).
#  - markdown requires BlueCloth
#  - textilize methods require RedCloth
# Example:
# "<b>coolness</b>".strip_tags -> "coolness" 

require 'singleton'

# Singleton to be called in wrapper module
class TextHelperSingleton
  include Singleton
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper #tag_options needed by auto_link
  include ActionView::Helpers::SanitizeHelper
end

# Wrapper module
module MyExtensions #:nodoc:
  module CoreExtensions #:nodoc:
    module String #:nodoc:
      module TextHelper
        def auto_link(link = :all, href_options = {}, &block)
          TextHelperSingleton.instance.auto_link(self, link, href_options, &block)
        end

        def excerpt(phrase, radius = 100, excerpt_string = "…")
          TextHelperSingleton.instance.excerpt(self, phrase, radius, excerpt_string)
        end

        def highlight(phrase, highlighter = '<strong class="highlight">\1</strong>')
          TextHelperSingleton.instance.highlight(self, phrase, highlighter)
        end
 
        def sanitize
          TextHelperSingleton.instance.sanitize(self)
        end

        def simple_format
          TextHelperSingleton.instance.simple_format(self)
        end

        def strip_tags
          TextHelperSingleton.instance.strip_tags(self)
        end

        def truncate(length = 30, truncate_string = "…")
          TextHelperSingleton.instance.truncate(self, length, truncate_string)
        end

        def word_wrap(line_width = 80)
          TextHelperSingleton.instance.word_wrap(self, line_width)
        end
      end
    end
  end
end

# extend String with the TextHelper functions
class String #:nodoc:
  include MyExtensions::CoreExtensions::String::TextHelper
end

def logger
  RAILS_DEFAULT_LOGGER
end

def normalise_url(url)
  begin
    uri = URI.parse(url)
    uri = URI.parse("http://#{uri}") unless uri.scheme
    uri.scheme = uri.scheme.downcase  # URI should do this
    uri.normalize.to_s
  rescue URI::InvalidURIError
    raise InvalidOpenId.new("#{url} is not an OpenID URL")
  end
end

# stupid simple logging:
def yell_log(file, msg)
  f = File.open(File.expand_path(File.dirname(__FILE__) + "/../log/#{file}.log"),"a")
  f.puts "#{Time.now.to_s} - #{msg}"
  f.close
end

def yell(msg)
  yell_log('yell', msg)
end

def log_test(msg)
  RAILS_DEFAULT_LOGGER.warn "#{Time.now.to_s} - #{msg}"
end
