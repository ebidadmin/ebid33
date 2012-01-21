require File.dirname(__FILE__) + '/../spec_helper'

describe Branch do
  it "should be valid" do
    Branch.new.should be_valid
  end
end
