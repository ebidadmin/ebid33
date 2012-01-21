require File.dirname(__FILE__) + '/../spec_helper'

describe Company do
  it "should be valid" do
    Company.new.should be_valid
  end
end
