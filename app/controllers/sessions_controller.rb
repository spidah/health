class SessionsController < ApplicationController
  before_filter :set_menu_item

  verify :method => :get, :only => :new, :redirect_to => 'new'
  verify :method => [:get, :post], :only => [:create, :signup], :redirect_to => 'new'
  verify :method => :delete, :only => :destroy, :redirect_to => 'new'

  def new
    redirect_to(dashboard_path) and return if (@current_user && @current_user.valid?)
    @user = UserLogin.new
  end

  def destroy
    session[:user_id] = nil
    reset_session
    redirect_to(home_path)
  end

  def create
    redirect_to dashboard_path and return if @current_user && @current_user.valid?

    if using_open_id?
      open_id_authentication
    else
      password_authentication(params[:loginname], params[:password])
    end
  end

  def signup
    if request.get?
      if session[:openid_url]
        @openid_login = session[:openid_url]
        session[:signup_loginname] = session[:openid_registration]['nickname']
      end
    elsif request.post?
      if session[:openid_url]
        oid_reg = session[:openid_registration]
        @user = User.new(:loginname => params[:loginname], :email => oid_reg['email'], :gender => oid_reg['gender'], :dob => oid_reg['dob'],
          :timezone => oid_reg['timezone'] || 'Europe/London')
      else
        @user = User.new(:loginname => params[:loginname], :gender => 'm', :dob => Date.today, :timezone => 'Europe/London')
      end

      if !@user.valid?
        session[:signup_loginname] = params[:loginname]
        flash[:signup_error] = @user.errors
        render and return
      end

      @user_login = UserLogin.new
      @user_login.loginname = params[:loginname]
      @user_login.password = params[:password]
      @user_login.password_confirmation = params[:password_confirmation]

      if !@user_login.valid?
        session[:signup_loginname] = params[:loginname]
        flash[:signup_error] = pick_error(@user_login.errors)
        render and return
      end

      @user.last_login = Time.now
      @user.save
      @user_login.user_id = @user.id
      @user_login.linked_to = -1
      @user_login.save

      UserLogin.create(:openid_url => session[:openid_url], :user_id => @user.id) if session[:openid_url]

      session[:user_id] = @user.id
      session[:user_login_id] = @user_login.id
      flash[:firstlogin] = 'true'
      redirect_to(edit_user_path)
    end
  end

  protected
    def set_menu_item
      @overridden_controller = 'home'
      @activemenuitem = ''
    end

    def pick_error(errors)
      passwords = errors.on(:password)
      if passwords
        if passwords.class == Array
          passwords.each {|msg| return msg if msg.match('enter') != nil}
          passwords.each {|msg| return msg if msg.match('between') != nil}
        else
          return passwords
        end
      end
    end

    def password_authentication(loginname, password)
      if @user = User.find(:first, :conditions => {:loginname => loginname})
        if @user_login = UserLogin.authenticate(@user.id, password)
          reset_session
          session[:user_id] = @user.id
          session[:user_login_id] = @user_login.id
          @user.last_login = Time.now
          @user.save
          redirect_to(dashboard_path)
          return
        else
          reset_session
          session[:login_loginname] = loginname
          session[:login_password] = password
          failed_login('Unable to log you in. Please check your loginname and password and try again.')
          return
        end
      else
        failed_login('Unable to log you in. Please check your loginname and password and try again.')
        return
      end
    end

    def open_id_authentication
      authenticate_with_open_id(params[:openid_url], :optional => [:nickname, :gender, :timezone]) do |result, identity_url, registration|
        if result.successful?
          if @user_login = UserLogin.get(identity_url)
            @user = User.find(@user_login.user_id)

            @user.last_login = Time.now
            @user.save

            temp = session[:return_to]
            reset_session
            session[:user_id] = @user.id
            session[:user_login_id] = @user_login.id
            session[:return_to] = temp

            successful_login
            return
          else
            reset_session
            session[:openid_url] = identity_url
            session[:openid_registration] = registration

            redirect_to signup_path
          end
        else
          failed_login(result.message || "Sorry, but we were unable to log you in using #{identity_url}")
        end
      end
    end

    def successful_login
      redirect_back_or_default(dashboard_path)
    end

    def failed_login(message)
      flash[:login_error] = message
      redirect_to(login_path)
    end

    def root_url
      open_id_complete_url
    end
end
