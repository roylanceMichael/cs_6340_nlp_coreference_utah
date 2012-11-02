require 'rexml/document'
require './parseAdapter.rb'
require './parseData.rb'
require './utilities.rb'
require './sentence.rb'
require './npModel.rb'

require './parseData.rb'
class Ncrf
  attr_accessor :xml, :fileName, :sentences, :nps, :seed, :parseAdapter
  
  #send in the xml as a string
  def initialize(xml, fileName)
    @xml = REXML::Document.new(xml) 
    @fileName = fileName
    @nps = []
    @seed = 0
    @parseAdapter = ParseAdapter.new
  end
  
  def newId
    @seed = @seed + 1
    "X#{@seed}"
  end
  
  #extract sentence structures
  def constructSentencesFromXml
    @sentences = []
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
          np = currentSentence.elementAdd element
          @nps.push np
        elsif element.class == REXML::Text
          
          #am I an existing sentence?
          existingSentence = false
          if currentSentence.sent.length != 0
            existingSentence = true
          end
          
          #there could me multiple sentences in this element
          element.to_s.split(/\n/).each do |sentence|
            
            #this is to ensure we grab the last part of a sentence
            if existingSentence
              existingSentence = false
            elsif currentSentence.sent.length != 0
              @sentences.push currentSentence
              currentSentence = Sentence.new
            end
            
            currentSentence.textAdd sentence
          end
          
        end
      end
    end
    
    if currentSentence.sent.length != 0
      sentences.push currentSentence
    end
  end
  
  #identify and add nps
  def identifyAddNps
    pd = ParseData.new
    @sentences.each do |sentence|
      strSent = sentence.strRep
      
      sentNps = @parseAdapter.parse strSent
      
      #in the future, do a little better on matching
      foundNps = pd.onlyNP sentNps
      
      foundNps.each do |foundNp|
        sentence.npAdd foundNp, newId
      end
      
    end
  end

end