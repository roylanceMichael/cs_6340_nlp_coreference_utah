require_relative './npModel.rb'
require_relative './utilities.rb'

#this class houses a sentence, which is just an array of words

class Sentence
  attr_accessor :sent, :npModels, :sentIdx
  
  def initialize
    @sent = []
    @npModels = []
    @acceptableNps = []
  end
  
  def strRep
    @sent.join " "
  end
  
  def xmlRep
    xmlSentence = ""
    idx = 0
    
    #going under the assumption that there is only startIdx, endIdx are unique
    @sent.each do |word|
      np = @npModels.select{|t| t.startIdx == idx && t.included == true}
      
      if np != nil && np.length > 0
        #handle the np...
        currentNp = np[0]
        
        #handle the case with a ref
        if currentNp.ref != nil
          xmlSentence = "#{xmlSentence} <COREF ID='#{currentNp.id}' REF='#{currentNp.ref.id}'>#{word}"
        else
          xmlSentence = "#{xmlSentence} <COREF ID='#{currentNp.id}'>#{word}"
        end
        
        if currentNp.endIdx == idx
          xmlSentence = "#{xmlSentence}</COREF>"
        end
        
        #including this next in here for sanity
        idx = idx + 1
        next
      end
      
      np = @npModels.select{|t| t.endIdx == idx && t.included == true}
      
      if np != nil && np.length > 0
        #handle the np...
        currentNp = np[0]
        xmlSentence = "#{xmlSentence} #{word}</COREF>"
        #including this in here for readability
        idx = idx + 1
        next
      end
      
      xmlSentence = "#{xmlSentence} #{word}"
      idx = idx + 1
    end
    
    xmlSentence.lstrip.rstrip
  end
  
  def addWord(word)
    @sent.push word
  end
  
  def textAdd(content)
    normalized = content.gsub(/\s+/, " ").lstrip.rstrip
    
    normalized.split(/\s+/).each do |word|
      addWord word
    end
  end
  
  def elementAdd(xmlElement)
    #get the start index for coref
    startIdx = @sent.length
    
    words = ""
    #this is the portion that adds the words
    xmlText = xmlElement.get_text.to_s.lstrip.rstrip
    xmlText.split(/\s+/).each do |word|
      words = "#{words} #{word}"
      addWord word
    end
    
    endIdx = @sent.length - 1
    
    # puts "endIdx => #{endIdx}, sentence => #{currentSentence} #{currentSentence.length}, words => #{words} #{words.length}"
    id = xmlElement.attributes["ID"]
    #return back!
    npModel = NpModel.new id, startIdx, endIdx, words.gsub(/\s+/, " ").lstrip.rstrip, self
    npModel.coref = true
    npModel.included = true
    @npModels.push npModel
    npModel
  end

  def npAdd(np, id)
    dumbNps = ["the"]
    if dumbNps.include? np.downcase
      return
    end

    util = Utilities.new
    
    result = util.sentIdxInfo(@sent, np.split(/\s+/))
    
    if result[:startIdx] != nil && result[:endIdx] != nil
      startIdx = result[:startIdx]
      endIdx = result[:endIdx]
      
      #we need to make sure that startIdx isn't within the start/end of existing
      #we need to make sure that endIdx isn't within the start/end of existing
      
      foundNps = @npModels.select{|t| t.startIdx <= startIdx && t.endIdx >= startIdx }
      if foundNps.length > 0
        return
      end
      
      foundNps = @npModels.select{|t| t.startIdx <= endIdx && t.endIdx >= endIdx }
      if foundNps.length > 0
        return
      end
      
      npModel = NpModel.new id, startIdx, endIdx, np.lstrip.rstrip, self
      npModel.coref = false
      npModel.included = false
      
      @npModels.push npModel
      
      cleanUpRogueNps
    end
  end
  
  #the purpose of this function is to remove all rogue nps
  #for example, we might get an np "union representatives"
  #and we might also get another np "union representatives who do something"
  #we want only the one with the longer length
  def cleanUpRogueNps

    removeNps = []
    @npModels.each do |acceptableNp|
      idx = 0
      
      @npModels.each do |otherNp|
        if otherNp.included == false && otherNp.id != acceptableNp.id && otherNp.startIdx == acceptableNp.startIdx && otherNp.endIdx <= acceptableNp.endIdx
          removeNps.push otherNp
        end
        idx = idx + 1
      end
    end
    
    while removeNps.length > 0
      removeNp = removeNps[0]
      
      removeIdx = 0
      @npModels.each do |np|
        if np.id == removeNp.id
          break
        end
        removeIdx = removeIdx + 1
      end
      
      @npModels.slice!(removeIdx)
      
      removeNps.slice!(0)
    end
  end
end