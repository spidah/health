class ActiveRecord::Base
  def self.fixed_point_number(*args)
    args.each do |arg|
      define_method arg.to_s + '=' do |number|
        write_attribute(arg, (number.to_f * 100).to_i)
      end

      define_method arg.to_s do
        read_attribute(arg).to_f / 100
      end
    end
  end

  def self.fixed_point_number_integer(*args)
    args.each do |arg|
      define_method arg.to_s + '=' do |number|
        write_attribute(arg, (number.to_f * 100).to_i)
      end

      define_method arg.to_s do
        (read_attribute(arg).to_f / 100).to_i
      end
    end
  end
end
