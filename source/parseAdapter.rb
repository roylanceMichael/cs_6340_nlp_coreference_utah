require 'java'
include Java
require 'source/stanford-parser/stanford-parser.jar'
java_import 'java.io.StringReader'
java_import 'edu.stanford.nlp.parser.lexparser.LexicalizedParser'
java_import 'edu.stanford.nlp.trees.PennTreebankLanguagePack'
java_import 'edu.stanford.nlp.process.DocumentPreprocessor'
java_import 'java.io.Reader'

class ParseAdapter
    attr_accessor :lp
    
    def initialize
      @lp = LexicalizedParser.getParserFromSerializedFile "source/stanford-parser/englishPCFG.ser.gz"
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

      return returnSentences
    end
end
