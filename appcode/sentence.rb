require './npModel.rb'
#this class houses a sentence, which is just an array of words
#we're going to do cool stuff with it as well to allow us to add xml tags
class Sentence
  attr_accessor :sent, :npModels
  
  def initialize
    @sent = []
    @npModels = []
  end
  
  def strRep
    @sent.join " "
  end
  
  def xmlRep
    xmlSentence = ""
    idx = 0
    
    #going under the assumption that there is only startIdx, endIdx are unique
    @sent.each do |word|
      np = @npModels.select{|t| t.startIdx == idx}
      
      if np != nil && np.length > 0
        #handle the np...
        currentNp = np[0]
        
        #handle the case with a ref
        if currentNp.ref != nil
          xmlSentence = "#{xmlSentence} <COREF ID='#{currentNp.id}' REF='#{currentNp.ref.id}'>#{word}"
        else
          xmlSentence = "#{xmlSentence} <COREF ID='#{currentNp.id}'>#{word}"
        end
        #including this next in here for sanity
        idx = idx + 1
        next
      end
      
      np = @npModels.select{|t| t.endIdx == idx}
      
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
    @npModels.push npModel
    npModel
  end
  
  
end