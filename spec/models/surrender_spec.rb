require File.dirname(__FILE__) + '/../spec_helper'

describe Surrender do
  it "should be valid" do
    Surrender.new.should be_valid
  end
end
