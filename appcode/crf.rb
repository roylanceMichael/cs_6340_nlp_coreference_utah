require 'rexml/document'
require './parseAdapter.rb'

class Crf
  attr_accessor :rawXml

  def initialize(content)
    @rawXml = REXML::Document.new(content) 
  end
  
  def allWords
    words = []
    #only grab first node
    if @rawXml != nil && @rawXml.length > 0
      rootXml = @rawXml[0]
      rootXml.each do |element|
        
        if element.class == REXML::Element
          element.get_text.to_s.split(/\s+/).each do |word|
            words.push word
          end
        elsif element.class == REXML::Text
          element.to_s.split(/\s+/).each do |word|
            words.push word
          end
        end
      
      end
    end
    words
  end
  
  def generateSentenceTuples
    sentenceTuples = []
    pa = ParseAdapter.new
    sentences.each do |sentence|
      parse = pa.executeParser sentence
      hash = {}
      hash[:sentence] = sentence
      hash[:parse] = parse
      sentenceTuples.push hash
    end
    sentenceTuples
  end
  
  def sentences
    sentences = []
    currentSentence = ""
    if @rawXml != nil && @rawXml.length > 0
      rootXml = @rawXml[0]
      rootXml.each do |element|
        
        #check if we're an element or raw text
        if element.class == REXML::Element
          
          element.get_text.to_s.split(/\s+/).each do |word|
            currentSentence = "#{currentSentence} #{word}"
          end
        
        elsif element.class == REXML::Text
          
          existingSentence = false
          if currentSentence != ""
            existingSentence = true
          end
          
          element.to_s.split(/\n/).each do |sentence|
            
            if existingSentence
              existingSentence = false
            elsif currentSentence != ""
              sentences.push currentSentence.lstrip.rstrip
              currentSentence = ""
            end
                        
            sentence.split(/\s+/).each do |word|
              currentSentence = "#{currentSentence} #{word}"
            end
          end
        
        end
      end
    end
    
    if currentSentence != ""
      sentences.push currentSentence.lstrip.rstrip
    end
    
    sentences
  end
  
  def corefs
    ret = []
    if @rawXml != nil && @rawXml.length > 0
      rootXml = @rawXml[0]
      rootXml.each do |element|
        if element.class == REXML::Element
          ret.push element
        end
      end
    end
    ret
  end
end