require File.dirname(__FILE__) + '/../spec_helper'

describe VarCompany do
  it "should be valid" do
    VarCompany.new.should be_valid
  end
end
