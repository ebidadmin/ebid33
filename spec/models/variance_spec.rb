require File.dirname(__FILE__) + '/../spec_helper'

describe Variance do
  it "should be valid" do
    Variance.new.should be_valid
  end
end
