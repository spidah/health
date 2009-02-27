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
    @measurement = @current_user.measurements.build(params[:measurement])
    @measurement.taken_on = current_date
    
    @measurement.save!
    redirect_to(measurements_url)
  rescue
    flash[:error] = @measurement.errors
    render(:action => 'new')
  end

  # GET measurements/edit/id
  def edit
    @measurement = @current_user.measurements.find(params[:id])
  rescue
    flash[:error] = 'Unable to edit the selected measurement.'
    redirect_to(measurements_url)
  end

  # PUT measurements/id
  def update
    @measurement = @current_user.measurements.find(params[:id])
    @measurement.update_attributes!(params[:measurement])

    redirect_to(measurements_url)
  rescue
    if @measurement
      flash[:error] = @measurement.errors
      redirect_to(edit_measurement_url(@measurement))
    else
      flash[:error] = 'Unable to update the selected measurement.'
      redirect_to(measurements_url)
    end
  end

  # DESTROY measurements/id
  def destroy
    @measurement = @current_user.measurements.find(params[:id])
    @measurement.destroy
  rescue
    flash[:error] = 'Unable to delete the selected measurement.'
  ensure
    redirect_to(measurements_url)
  end

  protected

  def set_menu_item
    @activemenuitem = 'menu-measurements'
  end
end
