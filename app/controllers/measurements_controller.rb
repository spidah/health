class MeasurementsController < ApplicationController
  before_filter :login_required, :set_menu_item

  verify :method => :get, :only => [:index, :new, :edit], :redirect_to => 'index'
  verify :method => :post, :only => [:create], :redirect_to => 'index'
  verify :method => :put, :only => [:update], :redirect_to => 'index'
  verify :method => :delete, :only => :destroy, :redirect_to => 'index'

  # GET measurements
  def index
    @measurements = @current_user.measurements.get_single_measurements('DESC', "taken_on = '#{current_date}'")
    @after = @current_user.measurements.get_multiple_measurements('ASC', "taken_on > '#{current_date}'", 3)
    after_count = @after.collect {|a| a.taken_on}.uniq.size
    @before = @current_user.measurements.get_multiple_measurements('DESC', "taken_on < '#{current_date}'", 6 - after_count)
  end

  # GET measurements/new
  def new
    @measurement = Measurement.new
  end

  # POST measurements
  def create
    @measurement = Measurement.new({:taken_on => current_date}.merge(params[:measurement]))

    if @current_user.measurements << @measurement
      redirect_to measurements_path
    else
      flash[:error] = @measurement.errors
      render :action => 'new'
    end
  end

  # GET measurements/edit/id
  def edit
    begin
      @measurement = @current_user.measurements.find(params[:id])
    rescue
      flash[:error] = 'Unable to edit the selected measurement.'
      redirect_to measurements_path
    end
  end

  # PUT measurements/id
  def update
    begin
      @measurement = @current_user.measurements.find(params[:id])
      @measurement.update_attributes!(params[:measurement])

      redirect_to measurements_path
    rescue
      if @measurement
        flash[:error] = @measurement.errors
        redirect_to edit_measurement_path(@measurement)
      else
        flash[:error] = 'Unable to update the selected measurement.'
        redirect_to measurements_path
      end
    end
  end

  # DESTROY measurements/id
  def destroy
    begin
      @measurement = @current_user.measurements.find(params[:id])
      @measurement.destroy
    rescue
      flash[:error] = 'Unable to delete the selected measurement.'
    end

    redirect_to measurements_path
  end

  protected
    def set_menu_item
      @activemenuitem = 'menu-measurements'
    end
end
