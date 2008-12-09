class FoodsController < ApplicationController
  before_filter :login_required, :set_menu_item

  verify :method => :get, :only => [:index, :new, :edit], :redirect_to => 'index'
  verify :method => :post, :only => [:create], :redirect_to => 'index'
  verify :method => :put, :only => [:update], :redirect_to => 'index'
  verify :method => :delete, :only => :destroy, :redirect_to => 'index'

  def index
    get_all_foods
    @food = Food.new
  end

  def new
    @food = Food.new
  end

  def create
    @food = Food.new(params[:food])
    if @current_user.foods << @food
      redirect_to(foods_path)
    else
      flash[:error] = @food.errors
      render(:action => 'new')
    end
  end

  def edit
    @food = @current_user.foods.find(params[:id])
  rescue
    flash[:error] = 'Unable to edit the selected food.'
    redirect_to(foods_path)
  end

  def update
    begin
      @food = @current_user.foods.find(params[:id])
    rescue
      flash[:error] = 'Unable to update the selected food.'
      redirect_to(foods_path) and return
    end
    
    if !@food.update_attributes(params[:food])
      flash[:error] = @food.errors
    end
    redirect_to(foods_path)
  end

  def destroy
    begin
      @food = @current_user.foods.find(params[:id])
      @food.destroy
    rescue
      flash[:error] = 'Unable to delete the selected food.'
    end
    redirect_to(foods_path)
  end

  protected
    def get_all_foods
      @foods = @current_user.foods.pagination(params[:page], params[:sort], params[:dir] ? 'DESC' : 'ASC')
    end

    def set_menu_item
      @activemenuitem = 'menu-meals'
      @overridden_controller = 'meals'
    end
end
