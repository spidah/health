class CalendarController < ApplicationController
  before_filter :login_required, :set_menu_item


  protected
    def set_menu_item
      @activemenuitem = 'menu-account'
    end
end
