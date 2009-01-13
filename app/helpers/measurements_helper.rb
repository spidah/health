module MeasurementsHelper
  def measurement_entry(units, m)
    if units == 'inches'
      select('measurement', 'measurement', SELECT_INCHES, :selected => m.measurement.to_s) + ' inches'
    else
      select('measurement', 'measurement', SELECT_CM, :selected => m.measurement.to_s) + ' cm'
    end
  end

  def format_measurement(units, m)
    "#{m.measurement.to_s} #{units}"
  end

  def measurement_difference(units, difference)
    if difference == 0
      '---'
    else
      direction = 'gained ' if difference > 0
      direction = 'lost ' if difference < 0
      if units == 'inches'
        direction + pluralize(difference.abs, 'inch')
      else
        direction + "#{difference.abs.to_s} #{units}"
      end
    end
  end
end
