require 'spec_helper'

describe CartController do

  describe "GET 'add'" do
    it "returns http success" do
      get 'add'
      response.should be_success
    end
  end

  describe "GET 'remove'" do
    it "returns http success" do
      get 'remove'
      response.should be_success
    end
  end

  describe "GET 'clear'" do
    it "returns http success" do
      get 'clear'
      response.should be_success
    end
  end

end
