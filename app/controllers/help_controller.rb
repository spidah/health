class HelpController < ApplicationController
  before_filter :login_required

  def activities
    @activemenuitem = 'menu-exercise'
  end

  def exercises
    @activemenuitem = 'menu-exercise'
  end

  def foods
    @activemenuitem = 'menu-meals'
  end

  def meals
    @activemenuitem = 'menu-meals'
  end

  def measurements
    @activemenuitem = 'menu-measurements'
  end

  def targetweights
    @activemenuitem = 'menu-weights'
  end

  def weights
    @activemenuitem = 'menu-weights'
  end
end