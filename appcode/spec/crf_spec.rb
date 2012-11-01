require 'spec_helper.rb'

describe Crf do 
  
  describe "#decId" do
    
    before :each do
      testLoc = "./devset/input/1.crf" 
      @content = (File.new testLoc).read
      @crf = Crf.new @content, "1"
    end
    
    it "decements the id for a given instance" do
      @crf.decId.should eq("X1")
    end
  end
  
  describe "#printXml" do
    
    before :each do
      testXml = "<TXT>The cat walked down the stairs.\n <COREF ID='1'>It</COREF> was looking for food.</TXT>"
      @crf = Crf.new testXml, "1"
    end
    
    it "prints out correctly" do
      return
      result = @crf.generateSentenceTuples
      @crf.updateCrfs
      result = @crf.printXml
      puts result
      result.should_not eq(nil)
    end
    
    it "prints out correctly, 1.crf" do
      return
      tXml = '<TXT>
       870123-0009. 
       Eastern Air Proposes Date
      For Talks on Pay-Cut Plan
       01/23/87
       WALL STREET JOURNAL (J)
       LABOR TEX
      AIRLINES (AIR) 
       MIAMI  


       <COREF ID="3">Eastern Airlines</COREF> executives notified union leaders that the carrier wishes to discuss selective wage reductions on <COREF ID="6">Feb. 3</COREF>.
       </TXT>'
       crfInstance = Crf.new tXml, "1"
       result = crfInstance.generateSentenceTuples
       crfInstance.updateCrfs
       puts "PRINTS OUT CORRECTLY - 1.crf"
       realXml = crfInstance.printRealXml
       
       puts realXml
       
       realXml.should_not eq(nil)
    
    end
    
  end
end
