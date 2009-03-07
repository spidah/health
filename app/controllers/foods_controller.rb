class FoodsController < ApplicationController
  before_filter :login_required, :set_menu_item
  before_filter :get_food, :only => [:edit, :update, :destroy]

  verify :method => :get, :only => [:index, :new, :edit], :redirect_to => 'index'
  verify :method => :post, :only => :create, :redirect_to => 'index'
  verify :method => :put, :only => :update, :redirect_to => 'index'
  verify :method => [:get, :delete], :only => :destroy, :redirect_to => 'index'

  def index
    get_all_foods
    @food = Food.new
  end

  def new
    @food = Food.new
  end

  def create
    @food = @current_user.foods.build(params[:food])
    @food.save!
    redirect_to(foods_url)
  rescue
    flash[:error] = @food.errors
    render(:action => 'new')
  end

  def edit
  end

  def update
    @food.update_attributes!(params[:food])
  rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
    flash[:error] = @food.errors
  ensure
    redirect_to(foods_url)
  end

  def destroy
    if request.delete?
      @food.destroy
      redirect_to(foods_url)
    end
  end

  protected

  def get_all_foods
    @foods = @current_user.foods.pagination(params[:page], params[:sort], params[:dir] ? 'DESC' : 'ASC')
  end

  def get_food
    @food = @current_user.foods.find(params[:id].to_i)
  rescue
    flash[:error] = 'Unable to find the selected food.'
    redirect_to(foods_url)
  end

  def set_menu_item
    @activemenuitem = 'menu-meals'
    @overridden_controller = 'meals'
  end
end
