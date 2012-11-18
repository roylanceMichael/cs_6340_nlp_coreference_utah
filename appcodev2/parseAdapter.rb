require 'java'
include Java
require 'stanford-parser/stanford-parser.jar'
require 'dword.rb'
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

      ignoreWords = [")", "(", "[", "'", "]", """", "'", ",", ".", "!", "?"]
      
      reader = StringReader.new(text)
      
      dp = DocumentPreprocessor.new(reader)
      
      charIdx = 0

      dp.each do |sentence|
        s = []
        
        sentence.each do |word|
          nWord = word.to_s.lstrip.rstrip

          if ignoreWords.include? nWord
            next
          elsif (nWord =~ /-.+-/) != nil
            next
          end

          dWord = Dword.new(nWord)
          dWord.charStart = charIdx
          dWord.charEnd = dWord.charStart  + nWord.length - 1

          charIdx = charIdx + nWord.length

          #puts "#{dWord} #{dWord.charStart} #{dWord.charEnd}"
          
          s.push dWord
        end
            
        returnSentences.push s
      end

      returnSentences
    end
end