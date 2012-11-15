require 'spec_helper.rb'

describe Document do
  
  describe "#genwords" do
    
    it "runs correctly" do
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
       doc = Document.new tXml, "1", "somewhere", nil
       doc.genwords
       doc.words.length.should eq(39)
    end
    
    it "links up sentences correctly" do
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
       doc = Document.new tXml, "1", "somewhere", nil
       doc.genwords
       doc.definesentences
       #puts doc.words
    end
  end

end