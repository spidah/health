require File.dirname(__FILE__) + '/../../lib/fixed_point_math'

class Item < ActiveRecord::Base
  fixed_point_number :price
end