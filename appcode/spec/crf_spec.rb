require 'spec_helper.rb'

describe Crf do 
  
  describe "#decId" do
    
    before :each do
      testLoc = "./devset/input/1.crf" 
      @content = (File.new testLoc).read
      @crf = Crf.new @content
    end
    
    it "decements the id for a given instance" do
      @crf.decId.should eq(-1)
    end
  end
  
  describe "#printXml" do
    
    before :each do
      testXml = "<TXT>The cat walked down the stairs.\n <COREF ID='1'>It</COREF> was looking for food.</TXT>"
      @crf = Crf.new testXml
    end
    
    it "prints out correctly" do
      result = @crf.generateSentenceTuples
      @crf.updateCrfs
      result = @crf.printXml
      puts result
      result.should_not eq(nil)
    end
    
  end
end
