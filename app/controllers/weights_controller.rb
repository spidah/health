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
      redirect_to(edit_weight_path(existing))
    else
      @weight = Weight.new
    end
  end

  # POST /weights
  def create
    @weight = @current_user.weights.build({:weight_units => @current_user.weight_units}.merge(params[:weight]))
    @weight.taken_on = current_date

    @weight.save!
    redirect_to(weights_path)
  rescue
    flash[:error] = @weight.errors
    render(:action => 'new')
  end

  # GET /weights/edit/1
  def edit
    @weight = @current_user.weights.find(params[:id].to_i)
  rescue
    flash[:error] = 'Unable to edit the selected weight.'
    redirect_to(weights_path)
  end

  # PUT /weights/1
  def update
    @weight = @current_user.weights.find(params[:id].to_i)
    @weight.update_attributes!({:weight_units => @current_user.weight_units}.merge(params[:weight]))

    redirect_to(weights_path)
  rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
    flash[:error] = @weight.errors
    redirect_to(edit_weight_path(@weight))
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Unable to update the selected weight.'
    redirect_to(weights_path)
  end

  # DESTROY /weights/1
  def destroy
    @weight = @current_user.weights.find(params[:id].to_i)
    @weight.destroy
  rescue
    flash[:error] = 'Unable to delete the selected weight.'
  ensure
    redirect_to(weights_path)
  end

  protected
  def set_menu_item
    @activemenuitem = 'menu-weights'
  end
end
