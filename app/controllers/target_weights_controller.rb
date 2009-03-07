class TargetWeightsController < ApplicationController
  before_filter :login_required, :set_menu_item
  before_filter :get_targetweight, :only => :destroy

  helper :weights

  verify :method => :get, :only => [:index, :new], :redirect_to => 'index'
  verify :method => :post, :only => [:create], :redirect_to => 'index'
  verify :method => [:get, :delete], :only => :destroy, :redirect_to => 'index'

  def index
    @target_weight = @current_user.target_weights.get_latest
    @current_weight = @current_user.weights.get_latest
  end

  def new
    existing = @current_user.target_weights.get_latest
    if existing && existing.achieved_on == nil
      redirect_to(targetweights_url)
    else
      @target_weight = TargetWeight.new
    end
  end

  def create
    existing = @current_user.target_weights.get_latest
    if existing && existing.achieved_on == nil
      redirect_to(targetweights_url)
    else
      @target_weight = TargetWeight.new({:weight_units => @current_user.weight_units, :created_on => @current_user.get_date}.merge(params[:weight]))

      if @current_user.target_weights << @target_weight
        TargetWeight.update_difference(@current_user)
        redirect_to(targetweights_url)
      else
        flash[:error] = @target_weight.errors
        render(:action => 'new')
      end
    end
  end

  def destroy
    if request.delete?
      begin
        @target_weight.destroy
      rescue
        flash[:error] = 'Unable to delete the target weight.'
      ensure
        redirect_to(targetweights_url)
      end
    end
  end

  protected

  def set_menu_item
    @activemenuitem = 'menu-weights'
    @overridden_controller = 'weights'
  end

  def get_targetweight
    @target_weight = @current_user.target_weights.find(params[:id].to_i)
  rescue
    flash[:error] = 'Unable to find the target weight.'
    redirect_to(targetweights_url)
  end
end
