require 'rexml/document'
require './parseAdapter.rb'
require './parseData.rb'
require './utilities.rb'

class Crf
  attr_accessor :rawXml, :name, :crfs, :nps, :seed, :sentences, :sentenceArrays

  def initialize(content, name)
    @rawXml = REXML::Document.new(content) 
    @sentenceArrays = []
    @name = name
    @sentences = []
    @crfs = []
    @nps = []
    @seed = 0
  end
  
  def saveOutput
    results = generateSentenceTuples
    updateCrfs
    xml = printRealXml
    tmpFile = "results/#{@name}.response"
    if File.exists?(tmpFile)
      File.delete(tmpFile)
    end
    
    file = File.open(tmpFile, "w")
    file.write xml
    file.close
    
    lstFile = "listfile.txt"
    if File.exists? lstFile
      File.delete(lstFile)
    end
    
    file = File.open(lstFile, "w")
    file.write tmpFile
    file.close
  end
  
  def actualNps
    returnNps = []
    @nps.each do |np|
      foundRefs = @crfs.select{|t| t[:ref] == np[:id]}
      if foundRefs.length > 0
        returnNps.push np
      end
    end
    returnNps
  end
  
  def printRealXml
    returnXml = "<TXT>\n"
    sentIdx = 0
    util = Utilities.new
    ids = []
    
    returnSentences = []
    @sentences.each do |sentence|
      returnSentences.push sentence.sub(/\s+/, " ").lstrip.rstrip
    end
    
    @sentences.each do |sentence|
      
      currentCrfs = @crfs.select{|crf| crf[:sentIdx] == sentIdx}
      updateSentence(currentCrfs, returnSentences)
      currentNps = actualNps.select{|np| np[:sentIdx] == sentIdx}
      updateSentence(currentNps, returnSentences)
      sentIdx = sentIdx + 1
      
    end
    returnSentences.each {|sent| returnXml = "#{returnXml}#{sent}\n"}
    returnXml = "#{returnXml}</TXT>"
    returnXml
  end
  
  def updateSentence(currentCrfs, returnSentences)
    currentCrfs.each do |crf|
      sent = returnSentences[crf[:sentIdx]]
      
      #this is a stupid fix, I know...
      sentArray = sent.split(/\s+/)
      
      tmpVar = false
      puts "id => #{crf[:id]}, phrase => #{crf[:phrase]}, start => #{crf[:startIdx]}, end => #{crf[:endIdx]}"
      
      r = "<COREF ID='" + crf[:id].to_s + "'"
      
      if crf[:ref] != nil
        r = "#{r} REF='" + crf[:ref].to_s + "'"
      end
      
      r = "#{r}>"
      sentArray[crf[:startIdx]] = "#{r}#{sentArray[crf[:startIdx]]}"
      sentArray[crf[:endIdx]] = "#{sentArray[crf[:endIdx]]}</COREF>"
      
      returnSentences[crf[:sentIdx]] = sentArray.join " "
    end
  end
  
  def printXml
    returnXml = "<TXT>\n"
    sentIdx = 0
    util = Utilities.new
    ids = []
    
    returnSentences = []
    @sentences.each do |sentence|
      returnSentences.push sentence
    end
    
    @sentences.each do |sentence|
      
      puts "This is the sentence => #{sentence}"
      currentCrfs = @crfs.select{|crf| crf[:sentIdx] == sentIdx}
      
      puts "Found crfs => "
      currentCrfs.each{|t| puts "#{t[:phrase]}, #{t[:startIdx]}, #{t[:endIdx]}, #{t[:id]}, #{t[:ref]}"}
      
      if currentCrfs == nil
        next
      end
      
      currentNps = []
      
      currentCrfs.each do |crf|
        localNps = @nps.select{|np| np[:id] == crf[:ref]}
        localNps.each {|np| currentNps.push np }
      end
      
      puts "Found nps"
      
      currentNps.each{|t| puts "#{t[:phrase]}, #{t[:startIdx]}, #{t[:endIdx]}, #{t[:id]}, #{t[:ref]}"}
      
      currentCrfs.each do |crf|
        sent = ""
        if crf[:sentIdx] != nil && returnSentences.length > crf[:sentIdx]
          sent = returnSentences[crf[:sentIdx]]
        else
          next
        end
        
        #this is a stupid fix, I know...
        sentArray = sent.split(/\s+/)
        
        tmpVar = false
        
        for i in crf[:startIdx]..crf[:endIdx]
          if (sentArray[i] =~ /COREF/) != nil
            tmpVar = true
          end
        end
        
        if tmpVar
          next
        end
        
        r = "<COREF ID='" + crf[:id].to_s + "'"
        
        if crf[:ref] != nil
          r = "#{r} REF='" + crf[:ref].to_s + "'"
        end
        
        r = "#{r}>"
        sentArray[crf[:startIdx]] = "#{r}#{sentArray[crf[:startIdx]]}"
        sentArray[crf[:endIdx]] = "#{sentArray[crf[:endIdx]]}</COREF>"
        
        returnSentences[crf[:sentIdx]] = sentArray.join " "
      end
      
      currentNps.each do |np|
        sent = ""
        if np[:sentIdx] != nil && returnSentences.length > np[:sentIdx]
          sent = returnSentences[np[:sentIdx]]
        else
          next
        end
        
        #this is a stupid fix, I know...
        sentArray = sent.split(/\s+/)
        tmpVar = false
        
        for i in np[:startIdx]..np[:endIdx]
          if (sentArray[i] =~ /COREF/) != nil
            tmpVar = true
          end
        end
        
        if tmpVar
          next
        end
        
        r = "<COREF ID='" + np[:id].to_s + "'"
        
        if np[:ref] != nil
          r = "#{r} REF='" + np[:ref].to_s + "'"
        end
        
        r = "#{r}>"
        sentArray[np[:startIdx]] = "#{r}#{sentArray[np[:startIdx]]}"
        sentArray[np[:endIdx]] = "#{sentArray[np[:endIdx]]}</COREF>"
        
        #r = "#{r}>#{np[:phrase]}</COREF>"
        #puts "BEFORE #{sent} => #{np[:phrase]}, #{r}"
        #sent = sent.gsub(np[:phrase], r)
        #puts "AFTER #{sent} => #{np[:phrase]}, #{r}"
        
        returnSentences[np[:sentIdx]] = sentArray.join " "
      end
      
      sentIdx = sentIdx + 1
    end

    returnSentences.each {|sent| returnXml = "#{returnXml}#{sent}\n"}
    returnXml = "#{returnXml}</TXT>"
    returnXml
  end
  
  #simple function to assign unique identifiers
  def decId
    @seed = @seed + 1
    "X#{@seed}"
  end
  
  #this is where we'll do a majority of our work
  def updateCrfs
    @crfs.each do |crf|
      #get nps that are earlier...
      if crf[:sentIdx] == 0
        acceptNps = @nps.select{|t| t[:sentIdx] == 0}
        
        if acceptNps.length > 0
          crf[:ref] = acceptNps[0][:id]
        end
      else
        acceptNps = @nps.select{|t| t[:sentIdx] == crf[:sentIdx] - 1}
        
        if acceptNps.length > 0
            np = acceptNps[0]
            crf[:ref] = np[:id]
        end
      end
    end
  end
  
  #we get both the NPS and the crfs made here
  def generateSentenceTuples
    sentenceTuples = []
    @nps = []
    @seed = 0
    pa = ParseAdapter.new
    pd = ParseData.new
    util = Utilities.new
    sentences.each do |sentence|
      parse = pa.executeParser sentence
      hash = {}
      hash[:sentence] = sentence
      hash[:parse] = parse
      npPhrase  = pd.onlyNP parse
      
      npPhrase.each do |phrase|
        # i can handle this better...
        res = util.returnIdxInfo sentence, phrase
        
        if res[:startIdx] != nil && res[:endIdx] != nil
          #does this same one exist already?
          existingCrfs = @crfs.select {|t| t[:sentIdx] == sentenceTuples.length && t[:startIdx] <= res[:startIdx] && t[:endIdx] >= res[:startIdx]}
          if existingCrfs.length > 0
            #puts "SKIPPED => #{phrase} #{res[:sentIdx]}, #{res[:startIdx]}, #{res[:endIdx]}"
            next
          end
          
          id = decId
          tmp = {:id => id, :sentIdx => sentenceTuples.length, :startIdx => res[:startIdx], :endIdx => res[:endIdx], :phrase => phrase.lstrip.rstrip }
          @nps.push tmp
        else
          next
        end
      end
      
      hash[:nps] = 
      sentenceTuples.push hash
    end
    sentenceTuples
  end
  
  def returnStartEnd(sentence, phrase)
    sentenceArray = sentence.split(/\s/)
    phraseArray = phrase.split(/\s/)
    
    count = 0
    phraseArray.each do |aWord|
      sentenceArray.each do |sWord|
        if sWord == aWord
          count = count + 1
        end
      end
    end
    
  
  end
  
  def sentenceArrays
    sentences = []
    currentSentence = []
    @crfs = []
    util = Utilities.new
    
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
          words = words.lstrip.rstrip
          currentSentence = "#{currentSentence} #{words}".lstrip.rstrip
          
          endIdx = currentSentence.lstrip.rstrip.split(/\s+/).length - 1
          puts "currentSentence => #{currentSentence}, end => #{endIdx}"
          
          #res = util.returnIdxInfo currentSentence, words
          #startIdx = res[:startIdx]
          #endIdx = res[:endIdx]
          
          # puts "endIdx => #{endIdx}, sentence => #{currentSentence} #{currentSentence.length}, words => #{words} #{words.length}"
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
  
  end
  
  #important function to populate crfs
  def sentences
    sentences = []
    currentSentence = ""
    @crfs = []
    util = Utilities.new
    
    if @rawXml != nil && @rawXml.length > 0
      rootXml = @rawXml[0]
      rootXml.each do |element|
        
        #check if we're an element or raw text
        if element.class == REXML::Element
          #get the start index for coref
          startIdx = currentSentence.lstrip.rstrip.split(/\s+/).length
          puts "currentSentence => #{currentSentence}, start => #{startIdx}"
          words = ""
          
          element.get_text.to_s.split(/\s+/).each do |word|
            words = "#{words} #{word}"
          end
          words = words.lstrip.rstrip
          currentSentence = "#{currentSentence} #{words}".lstrip.rstrip
          
          endIdx = currentSentence.lstrip.rstrip.split(/\s+/).length - 1
          puts "currentSentence => #{currentSentence}, end => #{endIdx}"
          
          #res = util.returnIdxInfo currentSentence, words
          #startIdx = res[:startIdx]
          #endIdx = res[:endIdx]
          
          # puts "endIdx => #{endIdx}, sentence => #{currentSentence} #{currentSentence.length}, words => #{words} #{words.length}"
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