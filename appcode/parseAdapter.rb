require 'java'
include Java
require 'stanford-parser/stanford-parser.jar'
include_class 'java.io.StringReader'
include_class 'edu.stanford.nlp.parser.lexparser.LexicalizedParser'
include_class 'edu.stanford.nlp.trees.PennTreebankLanguagePack'
include_class 'edu.stanford.nlp.process.DocumentPreprocessor'
include_class 'java.io.Reader'

class ParseAdapter
    attr_accessor :lp
    
    def initialize
      @lp = LexicalizedParser.getParserFromSerializedFile "englishPCFG.ser.gz"
    end
  
    def parse(sentence)
	    parse =	@lp.apply(sentence)
	    return parse.toString()	
    end
    
    def returnSentences(text)
      returnSentences = []
      
      reader = StringReader.new(text)
      
      dp = DocumentPreprocessor.new(reader)
      
      dp.each do |sentence|
        s = []
        
        sentence.each do |word|
          s.push word.to_s.lstrip.rstrip
        end
        
        returnSentences.push s
      end
      puts "the length of returnSentences is #{returnSentences[1].length}"
      returnSentences
    end
end