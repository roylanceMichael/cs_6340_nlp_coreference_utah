require 'rexml/document'
require 'pathname'
require './parseAdapter.rb'
require './parseData.rb'
require './utilities.rb'
#require './sentence.rb'
#require './npModel.rb'
require './dword.rb'

#this represents 1 crf file...
class Document
  attr_accessor :xml, :responseDir, :fileName, :words, :sentences
  
  def initialize(xml, responseDir, fileName, pa)
    @xml = REXML::Document.new(xml) 
    
    @responseDir = responseDir  
    @fileName = fileName
    
    @words = []
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
    currentSentence = Sentence.new
    
    if @xml != nil && @xml.length > 0
      #this is the TXT node...
      rootXml = @xml[0]
      
      #TODO: in the future we'll rely on the parser to tell us when
      #sentences end... for right now we'll just determine a hard return as the 
      #end of a sentence
      
      rootXml.each do |element|
        if element.class == REXML::Element
          
          tmpWords = Dword.elementFactory element
          
          tmpWords.each do |tmpWord|
            @words.push tmpWord
          end
          
        elsif element.class == REXML::Text
          
          tmpWords = Dword.textFactory(element)
          
          tmpWords.each do |tmpWord|
            @words.push tmpWord
          end
          
        end
      end
    end
  end
  
  #assuming that words have been defined already
  def definesentences
    
    givenSentences = @parseAdapter.returnSentences(printtext)
    #puts givenSentences[0]
    #puts givenSentences[1]
    #let's assume a one to one match for now...
    idx = 0
    givenSentences.each do |sentence|
      sentence.each do |word|
        @words[idx].sentIdx = idx
      end
      idx = idx + 1
      #puts idx
    end
  end
  
  def printtext
    return_text = ""
    
    @words.each do |word|
      return_text = "#{return_text} #{word}"
    end
    
    return_text
  end
end