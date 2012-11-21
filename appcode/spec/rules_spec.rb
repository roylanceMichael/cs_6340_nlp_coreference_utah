require 'spec_helper.rb'

describe Rules do

  describe "#proper names" do
  	it "correct identify" do
  		np1 = NpModel.new "1", 0, 2, "Mike Roylance", nil
  		np2 = NpModel.new "1", 0, 2, "Ben Nelson", nil

  		res = Rules.properNames(np1, np2)
  		res.should eq(true)
  	end
  end

    describe "#mismatch words" do
  		it "correct identify" do
  			np1 = NpModel.new "1", 0, 2, "The life of the wife", nil
  			np2 = NpModel.new "1", 0, 2, "The life of the fife", nil

  			res = Rules.mismatchWords(np1, np2)
  			res.should eq(0.2)
  		end
  	end

  	describe "#headnouns differ" do
  		it "correct identify" do
  			np1 = NpModel.new "1", 0, 2, "The life of the wife", nil
  			np2 = NpModel.new "1", 0, 2, "The life of the fife", nil

  			res = Rules.headnounsDiffer(np1, np2)
  			res.should eq(1)
	  	end
  	end

  	describe "#pronouns differ" do
  		it "correct identify" do
  			np1 = NpModel.new "1", 0, 2, "your", nil
  			np2 = NpModel.new "1", 0, 2, "Roylance", nil

  			res = Rules.pronounTypes(np1, np2)
  			res.should eq(0)
	  	end

	  	it "correct identify" do
  			np1 = NpModel.new "1", 0, 2, "Roylance", nil
  			np2 = NpModel.new "1", 0, 2, "your", nil

  			res = Rules.pronounTypes(np1, np2)
  			res.should eq(1)
	  	end
  	end
end