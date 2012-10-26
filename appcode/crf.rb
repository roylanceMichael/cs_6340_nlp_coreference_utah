require 'rexml/document'
require './parseAdapter.rb'
require './parseData.rb'

class Crf
  attr_accessor :rawXml, :crfs, :nps, :seed

  def initialize(content)
    @rawXml = REXML::Document.new(content) 
    @crfs = []
    @nps = []
    @seed = 0
  end
  
  def decId
    @seed = @seed - 1
    @seed
  end
  
  def updateCrfs
    @crfs.each do |crf|
      #get nps that are earlier...
      acceptNps = @nps.select{|t| t[:sentIdx] <= crf[:sentIdx]}
      idx = rand(acceptNps.length)
      np = acceptNps[idx]
      crf[:ref] = np[:id]
    end
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
    @nps = []
    @seed = 0
    pa = ParseAdapter.new
    pd = ParseData.new
    sentences.each do |sentence|
      parse = pa.executeParser sentence
      hash = {}
      hash[:sentence] = sentence
      hash[:parse] = parse
      npPhrase  = pd.onlyNP parse
      
      npPhrase.each do |phrase|
        startIdx = sentence.index phrase
        if startIdx == nil
          next
        end
        endIdx = startIdx + phrase.length
        id = decId
        tmp = {:id => id, :sentIdx => sentenceTuples.length, :startIdx => startIdx, :endIdx => endIdx }
        @nps.push tmp
      end
      
      hash[:nps] = 
      sentenceTuples.push hash
    end
    sentenceTuples
  end
  
  def sentences
    sentences = []
    currentSentence = ""
    @crfs = []
    if @rawXml != nil && @rawXml.length > 0
      rootXml = @rawXml[0]
      rootXml.each do |element|
        
        #check if we're an element or raw text
        if element.class == REXML::Element
          #get the start index for coref
          startIdx = currentSentence.length
          
          element.get_text.to_s.split(/\s+/).each do |word|
            currentSentence = "#{currentSentence} #{word}"
          end
          
          #get the end index for coref
          endIdx = currentSentence.length
          id = element.attributes["ID"]
          sentIdx = sentences.length
          th = {:id => id, :sentIdx => sentIdx, :startIdx => startIdx, :endIdx => endIdx }
          @crfs.push th
          
        elsif element.class == REXML::Text
          
          existingSentence = false
          if currentSentence != ""
            existingSentence = true
          end
          
          element.to_s.split(/\n/).each do |sentence|
            
            if existingSentence
              existingSentence = false
            elsif currentSentence != ""
              sentences.push currentSentence.gsub(/\s+/, " ").lstrip.rstrip
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
      sentences.push currentSentence.gsub(/\s+/, " ").lstrip.rstrip
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