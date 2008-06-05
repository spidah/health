module WeightsHelper
  def weight_entry(units, weight)
    if units == 'lbs'
      select('weight', 'stone', SELECT_STONE, :selected => weight.stone.to_s) + ' stone and ' +
        select('weight', 'lbs', SELECT_LBS, :selected => weight.lbs.to_s) + ' lbs'
    else
      select('weight', 'weight', SELECT_KG, :selected => weight.weight.to_s) + ' kg'
    end
  end

  def format_weight_number(units, weight)
    w = Weight.new(:weight => weight)
    w.format(units)
  end

  def weight_difference(units, difference)
    if difference == 0
      '---'
    else
      direction = 'gained ' if difference > 0
      direction = 'lost ' if difference < 0
      difference = difference.abs

      if units == 'lbs'
        if difference >= 14
          direction << "#{(difference / 14).to_s} stone "
          direction << pluralize((difference % 14), 'lb') if (difference % 14) != 0
        else
          direction << pluralize(difference, 'lb')
        end
      else
        direction << "#{difference.to_s} kg"
      end

      direction
    end
  end
end
