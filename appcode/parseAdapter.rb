require 'java'
include Java
require 'stanford-parser/stanford-parser.jar'
java_import 'java.io.StringReader'
java_import 'edu.stanford.nlp.parser.lexparser.LexicalizedParser'
java_import 'edu.stanford.nlp.trees.PennTreebankLanguagePack'
java_import 'edu.stanford.nlp.process.DocumentPreprocessor'
java_import 'java.io.Reader'

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
      i  = dp.iterator()
      while(i.hasNext())
	s = i.next()
	sentenceBuild = ""	
	s.each do |token|
	    if(sentenceBuild.length > 1)
		sentenceBuild << " "

	    end
	 sentenceBuild << token.toString()
	end

	returnSentences << sentenceBuild
      end
	puts returnSentences 
=begin
      dp.each do |sentence|
        s = []
        
        sentence.each do |word|
          s.push word.to_s.lstrip.rstrip
        end
        
        returnSentences.push s
      end
      puts "the length of returnSentences is #{returnSentences[1].length}"
      puts "ret sent #{returnSentences}"
=end
      return returnSentences
    end
end
