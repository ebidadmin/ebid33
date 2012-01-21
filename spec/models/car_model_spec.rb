require File.dirname(__FILE__) + '/../spec_helper'

describe CarModel do
  it "should be valid" do
    CarModel.new.should be_valid
  end
end
