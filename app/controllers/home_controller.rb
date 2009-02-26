class HomeController < ApplicationController
  before_filter :include_thumbnail_viewer, :only => :tour
  before_filter :include_news_stylesheet, :only => :index
  before_filter :set_menu_item
  protect_from_forgery :except => :contact

  def index
    flash[:error] = 'That page could not be found.' if params[:path]
    redirect_to(dashboard_url) and return if @current_user

    @news = NewsItem.find(:all, :limit => 3, :order => 'posted_on DESC')
  end

  def contact
    return if !request.post?

    errors = []
    check_and_add_error(errors, params[:name], 'Please enter your name.')
    check_and_add_error(errors, params[:email], 'Please enter a valid email.')
    check_and_add_error(errors, params[:subject], 'Please enter a subject.')
    check_and_add_error(errors, params[:comment], 'Please tell us what is on your mind.')

    if errors.size == 0
      Emailer.deliver_contact_form(params[:name], params[:email], params[:subject], params[:category], params[:comment])
      flash[:info] = 'Thank you for contacting us. Your comments will be read and a reply sent if needed.'
      redirect_to(home_url)
    else
      flash[:error] = errors
    end
  end

  protected

  def include_thumbnail_viewer
    include_extra_javascript('thumbnailviewer')
    include_extra_stylesheet('thumbnailviewer')
  end

  def include_news_stylesheet
    include_extra_stylesheet(:news)
  end

  def check_and_add_error(array, item, message)
    array << message if !item or item.blank?
  end

  def set_menu_item
    if @current_user
      @activemenuitem = 'menu-account'
      @overridden_controller = 'users'
    end
  end
end
