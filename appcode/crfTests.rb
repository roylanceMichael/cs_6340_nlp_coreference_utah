require './crf.rb'
require './parseAdapter.rb'

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
  
end