require 'rexml/document'
require './parseAdapter.rb'
require './parseData.rb'

class Crf
  attr_accessor :rawXml, :crfs, :nps, :seed, :sentences

  def initialize(content)
    @rawXml = REXML::Document.new(content) 
    @sentences = []
    @crfs = []
    @nps = []
    @seed = 0
  end
  
  def printXml
    returnXml = "<TXT>\n"
    sentIdx = 0
    
    returnSentences = []
    @sentences.each do |sentence|
      returnSentences.push sentence
    end
    
    @sentences.each do |sentence|
      currentCrfs = @crfs.select{|crf| crf[:sentIdx] == sentIdx}
      
      if currentCrfs == nil
        next
      end
      
      currentNps = []
      
      currentCrfs.each do |crf|
        localNps = @nps.select{|np| np[:id] == crf[:ref]}
        localNps.each {|np| currentNps.push np }
      end
      
      currentCrfs.each do |crf|
        sent = ""
        if crf[:sentIdx] != nil && returnSentences.length > crf[:sentIdx]
          sent = returnSentences[crf[:sentIdx]]
        else
          next
        end
        
        r = "<COREF ID='" + crf[:id].to_s + "'"
        
        if crf[:ref] != nil
          r = "#{r} REF='" + crf[:ref].to_s + "'"
        end
        
        r = "#{r}>#{crf[:phrase]}</COREF>"
        puts "BEFORE #{sent} => #{crf[:phrase]}, #{r}"
        sent = sent.gsub(crf[:phrase], r)
        puts "AFTER #{sent} => #{crf[:phrase]}, #{r}"
        
        returnSentences[crf[:sentIdx]] = sent
      end
      
      currentNps.each do |np|
        sent = ""
        if np[:sentIdx] != nil && returnSentences.length > np[:sentIdx]
          sent = returnSentences[np[:sentIdx]]
        else
          next
        end
        
        r = "<COREF ID='" + np[:id].to_s + "'"
        
        if np[:ref] != nil
          r = "#{r} REF='" + np[:ref].to_s + "'"
        end
        
        r = "#{r}>#{np[:phrase]}</COREF>"
        puts "BEFORE #{sent} => #{np[:phrase]}, #{r}"
        sent = sent.gsub(np[:phrase], r)
        puts "AFTER #{sent} => #{np[:phrase]}, #{r}"
        returnSentences[np[:sentIdx]] = sent
      end
      
      sentIdx = sentIdx + 1
    end

    returnSentences.each {|sent| returnXml = "#{returnXml}#{sent}\n"}
    returnXml = "#{returnXml}</TXT>"
    returnXml
  end
  
  #simple function to assign unique identifiers
  def decId
    @seed = @seed - 1
    @seed
  end
  
  #this is where we'll do a majority of our work
  def updateCrfs
    @crfs.each do |crf|
      #get nps that are earlier...
      acceptNps = @nps.select{|t| t[:sentIdx] <= crf[:sentIdx]}
      idx = rand(acceptNps.length)
      np = acceptNps[idx]
      crf[:ref] = np[:id]
    end
  end
  
  #we get both the NPS and the crfs made here
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
        tmp = {:id => id, :sentIdx => sentenceTuples.length, :startIdx => startIdx, :endIdx => endIdx, :phrase => phrase.lstrip.rstrip }
        @nps.push tmp
      end
      
      hash[:nps] = 
      sentenceTuples.push hash
    end
    sentenceTuples
  end
  
  #important function to populate crfs
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
          words = ""
          
          element.get_text.to_s.split(/\s+/).each do |word|
            words = "#{words} #{word}"
          end
          
          currentSentence = "#{currentSentence} #{words}"
          #get the end index for coref
          endIdx = currentSentence.length
          id = element.attributes["ID"]
          sentIdx = sentences.length
          th = {:id => id, :sentIdx => sentIdx, :startIdx => startIdx, :endIdx => endIdx, :phrase => words.lstrip.rstrip }
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
    @sentences = sentences
    sentences
  end
  
  #not using currently
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
  
  #not using currently
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
end