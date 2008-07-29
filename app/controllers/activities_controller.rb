class ActivitiesController < ApplicationController
  before_filter :login_required, :set_menu_item

  def index
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  protected
    def set_menu_item
      @activemenuitem = 'menu-exercise'
    end
end
