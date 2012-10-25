require './crf.rb'
require './parseAdapter.rb'
require './parseData.rb'

class CrfTests
  def runAll
      allTests = self.methods.select{|t| (t.to_s =~ /Test/) != nil}
      allTests.each do |test| 
        puts "executing #{test}, result is #{self.send test}"
      end
  end
  
  def successWhenSimpleXmlTest
    #arrange
    content = "<TXT>This is some text!</TXT>"
    #act
    crf = Crf.new(content)
    #assert
    #if we've gotten this far without an error, we pass
    true
  end
  
  def successWhenParseSentenceTest
    #arrange
    content = "<TXT>This is some text!</TXT>"
    crf = Crf.new(content)
    
    #act
    sentenceTuples = crf.generateSentenceTuples
    
    #assert
    puts sentenceTuples[0][:sentence]
    puts sentenceTuples[0][:parse]
    sentenceTuples != nil && sentenceTuples.length > 0
  end
  
  def parseTes
    #arrange
    content = "(ROOT Test)"
    pd = ParseData.new
    #act
    result = pd.processParen(content, 0)
    #assert
    puts result
    result != nil && result["ROOT"].lstrip.rstrip == "Test"
  end
  
  def parseTes2
    #arrange
    content = "(ROOT (DT Test))"
    pd = ParseData.new
    #act
    result = pd.processParen(content, 0)
    #assert
    puts result
    result != nil && result["ROOT"].class == Hash && result["ROOT"]["DT"].lstrip.rstrip == "Test"
  end
  
  def npOnlyTest1
    #arrange
    content = "(NP (DT Test))"
    pd = ParseData.new
    #act
    result = pd.onlyNP(content)
    #assert
    puts result
    result != nil && result[0] == "Test"
  end
  
  def npOnlyTest2
    #arrange
    content = "(NP (DT Test) (FF What) (CC The))"
    pd = ParseData.new
    #act
    result = pd.onlyNP(content)
    #assert
    puts result
    result != nil && result[0] == "Test What The"
  end
end