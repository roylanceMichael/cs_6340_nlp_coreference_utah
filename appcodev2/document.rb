require 'rexml/document'
require 'pathname'
require './parseAdapter.rb'
require './parseData.rb'
require './utilities.rb'
require './dword.rb'
require './coref.rb'
require './sentenceModel.rb'

#this represents 1 crf file...
class Document
  attr_accessor :xml, :words, :corefs, :sentences
  
  def initialize(xml, pa)
    @xml = REXML::Document.new(xml) 
    
    @words = []
    @corefs = []
    @sentences = []
    @seed = 0

  	if pa == nil
  		@parseAdapter = ParseAdapter.new
  	else
  		@parseAdapter = pa
  	end
  end
  
  #extract sentence structures
  def genwords
    @words = []
    @nps = []
    
    if @xml != nil && @xml.length > 0
      #this is the TXT node...
      rootXml = @xml[0]
      
      rootXml.each do |element|
        if element.class == REXML::Element
          
          #going to keep track of char index as well... useful when we need to match up the ids again
          Dword.elementFactory(element, @words)
          
        elsif element.class == REXML::Text
          
          Dword.textFactory(element, @words)
          
        end
      end
    end

    #generate the corefs here now...
    gencorefs
  end

  def gennps
    nps = @parseAdapter.parse printtext
    pd = ParseData.new
    res = pd.onlyNP nps
    puts res.length
    res.each do |result|
      puts result
    end
  end

  def gensentences
    sentences = @parseAdapter.returnSentences printtext

    sentIdx = 0
    sentences.each do |sentence|
      assignSentence(sentence, sentIdx)
      sentIdx = sentIdx + 1
    end
  end

  #given a sentence, I want to find out the best match for the words
  def assignSentence(sentence, sentIdx)
    sentenceLength = sentence.length - 1

    #I need to find the index of the words that don't have a length
    idx = 0
    @words.each do |word|
      if word.sentIdx == nil
        break
      end
      idx = idx + 1
    end

    #assuming that sentenceLength will either be right on or over. never under
    #going to give it 3 spaces to find an acceptable .?!
    tempIdx = idx + sentenceLength

    #puts "idx => #{idx} - tempIdx => #{tempIdx}"
    tmpSentence = SentenceModel.new
    tmpSentence.sentIdx = sentIdx

    for i in idx..tempIdx
      if @words[i] == nil
        next
      end
      
      tmpSentence.addWord @words[i]

      @words[i].sentIdx = sentIdx
    end

    @sentences.push tmpSentence
  end

  def gencorefs
    @corefs = []
    corefArray = @words.select{|t| t.wordid != nil }

    tempCoref = Coref.new

    corefArray.each do |coref|

      if coref.wordid != tempCoref.wordid
        
        if tempCoref.wordid != nil
          @corefs.push tempCoref
        end

        tempCoref = Coref.new
        tempCoref.addword(coref)
        coref.coref = tempCoref

      else
        
        tempCoref.addword(coref)
        coref.coref = tempCoref

      end
    end
  end
  
  def printtext
    return_text = ""
    
    @words.each do |word|
      return_text = "#{return_text} #{word.word}"
    end
    
    return_text
  end

  def printxml
    return_text = "<TXT>"

    #handle it on the sentence level...

    return_text = "#{return_text}</TXT>"
    return_text
  end
end