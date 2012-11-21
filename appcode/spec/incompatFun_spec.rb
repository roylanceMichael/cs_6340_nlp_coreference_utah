require 'spec_helper.rb'

describe IncompatFun do

  describe "#proper names" do
  	it "correct identify" do
  		np1 = NpModel.new "1", 0, 2, "Mike Roylance", nil
  		np2 = NpModel.new "1", 0, 2, "Ben Nelson", nil

  		res = IncompatFun.properNames(np1, np2)
  		res.should eq(1)
  	end
  end
end