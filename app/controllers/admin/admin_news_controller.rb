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
    begin
      @item = NewsItem.new(params[:news_item])
      @item.posted_on = Date.today
      @item.save!
      redirect_to admin_news_index_path
    rescue
      flash[:error] = @item.errors
      render :action => 'new'
    end
  end

  def edit
    begin
      @item = NewsItem.find(params[:id])
    rescue
      redirect_to admin_news_index_path
    end
  end

  def update
    begin
      @item = NewsItem.find(params[:id])
      @item.update_attributes!(params[:news_item])
      redirect_to admin_news_index_path
    rescue
      flash[:error] = @item.errors
      render :action => 'edit'
    end
  end

  def destroy
    begin
      news = NewsItem.find(params[:id])
      news.destroy
    rescue
      flash[:error] = 'Unable to delete the selected news item.'
    end

    redirect_to admin_news_index_path
  end

  protected
    def override_controller
      @overridden_controller = 'admin_news'
    end
    
    def set_menu_item
      @activemenuitem = 'menu-admin'
    end
end
