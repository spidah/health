class MeasurementsController < ApplicationController
  before_filter :login_required, :set_menu_item
  before_filter :get_measurement, :only => [:edit, :update, :destroy]
  before_filter :check_cancel, :only => [:create, :update, :destroy]

  verify :method => :get, :only => [:index, :new, :edit], :redirect_to => 'index'
  verify :method => :post, :only => [:create], :redirect_to => 'index'
  verify :method => :put, :only => [:update], :redirect_to => 'index'
  verify :method => [:get, :delete], :only => :destroy, :redirect_to => 'index'

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
  end

  # PUT measurements/id
  def update
    @measurement.update_attributes!(params[:measurement])
    redirect_to(measurements_url)
  rescue
    flash[:error] = @measurement.errors
    redirect_to(edit_measurement_url(@measurement))
  end

  # DESTROY measurements/id
  def destroy
    if request.delete?
      begin
        @measurement.destroy
      rescue
        flash[:error] = 'Unable to delete the selected measurement.'
      ensure
        redirect_to(measurements_url)
      end
    end
  end

  protected

  def set_menu_item
    @activemenuitem = 'menu-measurements'
  end

  def get_measurement
    @measurement = @current_user.measurements.find(params[:id].to_i)
  rescue
    flash[:error] = 'Unable to find the selected measurement.'
    redirect_to(measurements_url)
  end

  def check_cancel
    redirect_to(measurements_url) if params[:cancel]
  end
end
