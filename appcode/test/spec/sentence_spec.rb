require 'spec_helper.rb'

describe Sentence do

  describe "#textAdd" do
    
    it "can add a word" do
      sent = Sentence.new
      sent.textAdd "This is some cool text"
      sent.sent.length.should eq(5)
    end
  
  end
  
  describe "#elementAdd" do
    
    it "can add element" do
      sent = Sentence.new
      elem = REXML::Element.new "COREF"
      elem.add_attribute "ID", 1
      elem.text = "This is some cool text"
      res = sent.elementAdd elem
      sent.sent.length.should eq(5)
      res.id.should eq("1")
      res.startIdx.should eq(0)
      res.endIdx.should eq(4)
    end
  end

end