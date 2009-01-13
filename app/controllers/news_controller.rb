class NewsController < ApplicationController
  before_filter :override_controller
  before_filter :include_news_stylesheet

  def index
    @news = NewsItem.pagination(params[:page])
  end

  protected
    def override_controller
      @overridden_controller = 'home'
    end

    def include_news_stylesheet
      include_extra_stylesheet :news
    end
end
