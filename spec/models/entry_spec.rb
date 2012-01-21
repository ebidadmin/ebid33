require File.dirname(__FILE__) + '/../spec_helper'

describe Entry do
  it "should be valid" do
    Entry.new.should be_valid
  end
end
