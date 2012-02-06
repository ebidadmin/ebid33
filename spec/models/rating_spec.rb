require File.dirname(__FILE__) + '/../spec_helper'

describe Rating do
  it "should be valid" do
    Rating.new.should be_valid
  end
end
