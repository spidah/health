class Admin::AdminController < ApplicationController
  before_filter :admin_required
  before_filter :set_menu_item

  protected
    def set_menu_item
      @activemenuitem = 'menu-account'
    end
end
