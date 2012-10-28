require 'java'
include Java
require 'stanford-parser/stanford-parser.jar'
include_class 'java.io.StringReader'
include_class 'edu.stanford.nlp.parser.lexparser.LexicalizedParser'
include_class 'edu.stanford.nlp.trees.PennTreebankLanguagePack'

module ParseAdapter
=begin  attr_accessor :execPath, :tempFile
  
  def initialize
    @execPath = "java -mx150m -cp stanford-parser/*: edu.stanford.nlp.parser.lexparser.LexicalizedParser -outputFormat penn,typedDependencies edu/stanford/nlp/models/lexparser/englishPCFG.ser.gz"
    @tempFile = "stanford-parser/temp/temp.txt"
  end
  
  def executeParser(sentence)
    if File.exists?(@tempFile)
      File.delete(@tempFile)
    end 
    
    file = File.open(@tempFile, "w")
    file.write sentence
    file.close
    
    result = %x(#{@execPath} #{@tempFile})
    result
  end
=end
    def ParseAdapter.parse(sentence)
	lp = LexicalizedParser.getParserFromSerializedFile "englishPCFG.ser.gz"
	parse =	lp.apply(sentence)
	return parse.toString()	
    end
end
