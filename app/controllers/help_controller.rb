class HelpController < ApplicationController
  before_filter :login_required

  def measurements
    @activemenuitem = 'menu-measurements'
  end

  def weights
    @activemenuitem = 'menu-weights'
  end
end