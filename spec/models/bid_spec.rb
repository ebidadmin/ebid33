require File.dirname(__FILE__) + '/../spec_helper'

describe Bid do
  it "should be valid" do
    Bid.new.should be_valid
  end
end
