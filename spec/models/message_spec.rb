require File.dirname(__FILE__) + '/../spec_helper'

describe Message do
  it "should be valid" do
    Message.new.should be_valid
  end
end
