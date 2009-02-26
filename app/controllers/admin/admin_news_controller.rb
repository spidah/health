class Admin::AdminNewsController < ApplicationController
  before_filter :admin_required
  before_filter :override_controller, :set_menu_item

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
    @item = NewsItem.find(params[:id])
  rescue
    redirect_to(admin_news_index_url)
  end

  def update
    @item = NewsItem.find(params[:id])
    @item.update_attributes!(params[:news_item])
    redirect_to(admin_news_index_url)
  rescue
    flash[:error] = @item.errors
    redirect_to(edit_admin_news_url(@item))
  end

  def destroy
    news = NewsItem.find(params[:id])
    news.destroy
  rescue
    flash[:error] = 'Unable to delete the selected news item.'
  ensure
    redirect_to(admin_news_index_url)
  end

  protected
  
  def override_controller
    @overridden_controller = 'admin_news'
  end

  def set_menu_item
    @activemenuitem = 'menu-account'
  end
end
