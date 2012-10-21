class ParseAdapter
  attr_accessor :execPath, :tempFile
  
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
end