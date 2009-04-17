require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/model/item'

describe 'An item model that calls fixed_point_math' do
  before(:each) do
    @item = Item.new
    @item.price = 10.99
  end

  it 'should store a decimal point value as a fixed point integer' do
    @item.price_before_type_cast.should == 1099
  end

  it 'should store and return a decimal point value' do
    @item.price.should == 10.99
  end

  it 'should return as a float' do
    @item.price = 10
    @item.price.should == 10.0
  end
end