require 'spec_helper.rb'

describe Ncrf do

  describe "#constructSentencesFromXml" do
    
    it "can add a word" do
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
       crfInstance = Ncrf.new tXml, "1", nil
       crfInstance.constructSentencesFromXml
       crfInstance.sentences.length.should eq(9)
       crfInstance.sentences[0].strRep.should eq("870123-0009.")
       crfInstance.sentences[1].strRep.should eq("Eastern Air Proposes Date")
       crfInstance.sentences[2].strRep.should eq("For Talks on Pay-Cut Plan")
       crfInstance.sentences[3].strRep.should eq("01/23/87")
       crfInstance.sentences[4].strRep.should eq("WALL STREET JOURNAL (J)")
       crfInstance.sentences[5].strRep.should eq("LABOR TEX")
       crfInstance.sentences[6].strRep.should eq("AIRLINES (AIR)")
       crfInstance.sentences[7].strRep.should eq("MIAMI")
       crfInstance.sentences[8].strRep.should eq("Eastern Airlines executives notified union leaders that the carrier wishes to discuss selective wage reductions on Feb. 3 .")
    end
    
    it "xmlRep constructs the xml back again" do
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
       crfInstance = Ncrf.new tXml, "1", nil
       crfInstance.constructSentencesFromXml
       crfInstance.sentences.length.should eq(9)
       crfInstance.sentences[8].xmlRep.should eq("<COREF ID='3'>Eastern Airlines</COREF> executives notified union leaders that the carrier wishes to discuss selective wage reductions on <COREF ID='6'>Feb. 3</COREF> .")
    end
  
  end
  
  describe "#identifyAddNps" do
    
    it "first test" do
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
       crfInstance = Ncrf.new tXml, "1", nil
       crfInstance.constructSentencesFromXml
       crfInstance.identifyAddNps
       #no exceptions means pass
    end
  end
  
  describe "#applyNps" do
    
    it "first test" do
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
       crfInstance = Ncrf.new tXml, "1", nil
       crfInstance.constructSentencesFromXml
       crfInstance.identifyAddNps
       crfInstance.applyNps
       
       crfInstance.sentences.each do |sentence|
        puts sentence.xmlRep
       end
       
    end
  end

end
