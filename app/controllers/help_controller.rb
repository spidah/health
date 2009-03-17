class HelpController < ApplicationController
  before_filter :login_required

  def weights
    @activemenuitem = 'menu-weights'
  end
end