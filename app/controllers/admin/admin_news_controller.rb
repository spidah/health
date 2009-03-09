class Admin::AdminNewsController < ApplicationController
  before_filter :admin_required
  before_filter :override_controller, :set_menu_item
  before_filter :get_news_item, :only => [:edit, :update, :destroy]

  def index
    @news = NewsItem.pagination(params[:page])
  end

  def new
    @item = NewsItem.new(:posted_on => Date.today)
  end

  def create
    @item = NewsItem.new(params[:news_item])
    @item.posted_on = Date.today
    @item.save!
    redirect_to(admin_news_index_url)
  rescue
    flash.now[:error] = @item.errors
    render(:action => 'new')
  end

  def edit
  end

  def update
    @item.update_attributes!(params[:news_item])
    redirect_to(admin_news_index_url)
  rescue
    flash[:error] = @item.errors
    redirect_to(edit_admin_news_url(@item))
  end

  def destroy
    if request.delete?
      @item.destroy
      redirect_to(admin_news_index_url)
    end
  end

  protected
  
  def override_controller
    @overridden_controller = 'admin_news'
  end

  def set_menu_item
    @activemenuitem = 'menu-account'
  end

  def get_news_item
    @item = NewsItem.find(params[:id].to_i)
  rescue
    redirect_to(admin_news_index_url)
  end
end
