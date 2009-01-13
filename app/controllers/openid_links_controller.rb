class OpenidLinksController < ApplicationController
  before_filter :login_required

  verify :method => [:get, :post], :only => :create, :redirect_to => {:controller => 'users', :action => 'edit'}
  verify :method => :delete, :only => :destroy, :redirect_to => {:controller => 'users', :action => 'edit'}

  # action for adding an OpenID account link
  def create
    if params[:openid_link] && oid = UserLogin.get(OpenIdAuthentication.normalize_url(params[:openid_link]))
      if oid.user_id == @current_user.id
        flash[:openid_error] = "You have already linked #{params[:openid_link]} to your account."
      else
        flash[:openid_error] = "Someone has already linked #{params[:openid_link]} to their account."
      end

      redirect_to edit_user_path
    else
      authenticate_linked_openid(params[:openid_link])
    end
  end

  # action for unlinking an OpenID account
  def destroy
    begin
      openid = UserLogin.find(params[:id], :conditions => ['user_id == ?', @current_user.id])
      openid.destroy
      flash[:info] = "OpenID login #{openid.openid_url} has been unlinked."
    rescue
      flash[:openid_error] = 'Unable to remove the link. Please go back and try again.'
    end

    redirect_to edit_user_path
  end

  protected
    def authenticate_linked_openid(openid_link = nil)
      authenticate_with_open_id(openid_link) do |result, identity_url, registration|
        if result.successful?
          UserLogin.create(:openid_url => identity_url, :user_id => @current_user.id)
          flash[:info] = "OpenID login #{identity_url} was successfully linked to your account. You may now login using it."
          redirect_to edit_user_path
        else
          flash[:error] = "You failed to login #{identity_url} correctly and it has not been added to the list of linked OpenID accounts."
          redirect_to edit_user_path
        end
      end
    end
end
