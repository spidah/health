# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Stop GWA and other pre-fetchers
  include LinkPrefetchingBlock
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_health_session_id'
  protect_from_forgery
  before_filter :get_user
  helper_method :current_date

  # filters used through the app

  def get_user
    @current_user ||= User.find(session[:user_id])
  rescue
    @current_user = nil
  end

  # other methods

  def include_extra_javascript(*source)
    @extra_javascripts ||= []
    source.each { |file| @extra_javascripts << file.to_s }
  end

  def include_extra_stylesheet(*source)
    @extra_stylesheets ||= []
    source.each { |file| @extra_stylesheets << file.to_s }
  end

  def current_date
    session[:displaydate] || @current_user.get_date
  end

  def login_required
    return true if @current_user

    store_location
    redirect_to(login_url)
  end

  def admin_required
    return true if @current_user && @current_user.admin
    redirect_to(dashboard_url)
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    if session[:return_to].nil?
      redirect_to(default)
    else
      redirect_to(session[:return_to])
      session[:return_to] = nil
    end
  end
end
