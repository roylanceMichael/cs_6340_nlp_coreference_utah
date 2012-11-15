require 'java'
include Java
require 'stanford-parser/stanford-parser.jar'
include_class 'java.io.StringReader'
include_class 'edu.stanford.nlp.parser.lexparser.LexicalizedParser'
include_class 'edu.stanford.nlp.trees.PennTreebankLanguagePack'

class ParseAdapter
    attr_accessor :lp
    
    def initialize
      @lp = LexicalizedParser.getParserFromSerializedFile "englishPCFG.ser.gz"
    end
  
    def parse(sentence)
	    parse =	@lp.apply(sentence)
	    return parse.toString()	
    end

    def testNotExec(exec)
	if(exec)
	    return 1
	else
	    return 0
	end
    end
end
