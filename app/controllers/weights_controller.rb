class WeightsController < ApplicationController
  before_filter :login_required
  before_filter :set_menu_item

  verify :method => :get, :only => [:index, :new, :edit], :redirect_to => 'index'
  verify :method => :post, :only => [:create], :redirect_to => 'index'
  verify :method => :put, :only => [:update], :redirect_to => 'index'
  verify :method => :delete, :only => :destroy, :redirect_to => 'index'

  # GET /weights
  def index
    @weight = @current_user.get_weights(:first, 'DESC', ['taken_on = ?', current_date])
    @after = @current_user.get_weights(:all, 'ASC', ['taken_on > ?', current_date], 3).reverse
    @before = @current_user.get_weights(:all, 'DESC', ['taken_on < ?', current_date], 6 - @after.size)
  end

  # GET /weights/new
  def new
    if existing = @current_user.get_weights(:first, 'DESC', {:taken_on => current_date})
      redirect_to edit_weight_path(existing)
    else
      @weight = Weight.new
    end
  end

  # POST /weights
  def create
    @weight = Weight.new({:weight_units => @current_user.weight_units}.merge(params[:weight]))
    @weight.taken_on = current_date

    if @current_user.weights << @weight
      redirect_to weights_path
    else
      flash[:error] = @weight.errors
      render :action => 'new'
    end
  end

  # GET /weights/edit/1
  def edit
    begin
      @weight = @current_user.weights.find(params[:id])
    rescue
      flash[:error] = 'Unable to edit the selected weight.'
      redirect_to weights_path
    end
  end

  # PUT /weights/1
  def update
    begin
      @weight = @current_user.weights.find(params[:id])
      @weight.update_attributes!({:weight_units => @current_user.weight_units}.merge(params[:weight].except(:taken_on)))

      redirect_to weights_path
    rescue
      if @weight
        flash[:error] = @weight.errors
        redirect_to edit_weight_path(@weight)
      else
        flash[:error] = 'Unable to update the selected weight.'
        redirect_to weights_path
      end
    end
  end

  # DESTROY /weights/1
  def destroy
    begin
      @weight = @current_user.weights.find(params[:id])
      @weight.destroy
    rescue
      flash[:error] = 'Unable to delete the selected weight.'
    end

    redirect_to weights_path
  end

  protected
  def set_menu_item
    @activemenuitem = 'menu-weights'
  end
end
