require 'spec_helper'

describe RegionsController do

  describe "GET 'selected'" do
    it "returns http success" do
      get 'selected'
      response.should be_success
    end
  end

end
