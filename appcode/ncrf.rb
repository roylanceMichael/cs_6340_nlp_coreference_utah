require 'rexml/document'
require './parseAdapter.rb'
require './parseData.rb'
require './utilities.rb'
require './sentence.rb'
require './npModel.rb'

class Ncrf
  attr_accessor :xml, :fileName, :sentences, :nps, :seed, :parseAdapter
  
  #factory method for reading in a ton
  def self.factory(inputLoc)
	#inputLoc is a directory, read all files and process each one
	pa = ParseAdapter.new
	listFileContent = ""
	
	Dir.mkdir("results") unless File.exists?("results")
	
	Dir.foreach(inputLoc) do |file|
		if (file =~ /(.+)\.crf/) != nil
			puts "processing #{$1}.crf..."
			content = (File.new "#{inputLoc}/#{$1}.crf").read
			ncrf = Ncrf.new content, $1, pa
			ncrf.produceXml
			
			#the scorer doesn't like empty results...
			if listFileContent == ""
		    listFileContent = "results/#{$1}.response"
		  else
		    listFileContent = "#{listFileContent}\nresults/#{$1}.response"
		  end
		end
	end
	
    lstFile = "listfile.txt"
    if File.exists? lstFile
      File.delete(lstFile)
    end
    
    file = File.open(lstFile, "w")
    file.write listFileContent.lstrip.rstrip
    file.close
  end
  
  #send in the xml as a string
  def initialize(xml, fileName, pa)
    @xml = REXML::Document.new(xml) 
    @fileName = fileName
    @nps = []
    @seed = 0
	if pa == nil
		@parseAdapter = ParseAdapter.new
	else
		@parseAdapter = pa
	end
  end
  
  def produceXml
	constructSentencesFromXml
	identifyAddNps
	applyNps
	saveOutput
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
  
  #this is where we'll apply most of our logic
  def applyNps
    currentIdx = 0
    
    @sentences.each do |sentence|
      
      #right now we're just going to select the first NP per sentence... this will need to be fixed later
      sentence.npModels.each do |npModel|
        if npModel.coref
          #handle if we have a "they" in there
          if(findItAnt(npModel, currentIdx))
          elsif(findTheyAnt(npModel, currentIdx))
          elsif(findSimilarName(npModel, currentIdx))
          else
            findCorrectAnt(npModel, currentIdx)
          end
        end
      end
      currentIdx = currentIdx + 1
    end
  end
  
  #rules, apply when we find them
  
  #it usually belongs to the sentence right before it. 
  def findItAnt(npModel, sentIdx)
    if(npModel.phrase.downcase.lstrip.rstrip == "it" && sentIdx > 0)
      prevSent = @sentences[sentIdx - 1]
      
      #get the first np
      firstNp = prevSent.npModels.sort{|a, b| a.startIdx <=> b.startIdx}
      
      if firstNp.length > 0
        firstNp[0].included = true
        npModel.ref = firstNp[0]
        
        return true
      end
    end
    false
  end
  
  def findTheyAnt(npModel, sentIdx)
    pronoun = npModel.phrase.downcase.lstrip.rstrip
    pronouns = ["i", "me", "my", "mine", "myself", "you", "your", "yours", 
      "yourself", "we", "us", "our", "ours", "ourselves", "yourselves", "she",
      "he", "him", "his", "himself", "hers", "her", "herself", "they", "them",
      "their", "theirs", "themselves"]
    
    if (pronouns.include?(pronoun))
      sent = @sentences[sentIdx]
      
      #we need the first NP that is before this one
      acceptableNps = sent.npModels.select{|t| t.endIdx < npModel.startIdx}
      if acceptableNps.length > 0
        lastAcceptableNp = acceptableNps[acceptableNps.length - 1]
        
        lastAcceptableNp.included = true
        npModel.ref = lastAcceptableNp
        true
      else
        false
      end
    else
      false
    end
  end
  
  def findSimilarName(npModel, sentIdx)
    prevSentences = []
    
    for i in 0..sentIdx
      prevSentences.push @sentences[i]
    end
    
    #starting at the beginning, find the first np with any sort of match to our current phrase
    npPhrase = npModel.phrase.split(/\s+/)
    regexs = []
    npPhrase.each do |word|
      regex = Regexp.new word.downcase
      regexs.push regex
    end
    
    match = false
    
    prevSentences.each do |prevSent|
      
      prevSent.npModels.each do |acceptableNp|
        
        regexs.each do |regex|
          
          if acceptableNp.phrase.downcase =~ regex
            match = true
            break
          end
          
        end
        
        if match
          #this acceptableNp is a match
          acceptableNp.included = true
          npModel.ref = acceptableNp

          return true
        end
      end
    end
    
    false
  end
  
  def findCorrectAnt(npModel, sentIdx)
    #right now, just going to find the first np in the preceding sentence
    if sentIdx > 0
      preSentIdx = sentIdx - 1
      preSent = @sentences[preSentIdx]
      
      #do I exist in my npModels right now?
      stanfordNps = preSent.npModels.select{|t| t.coref == false }
      
      if stanfordNps.length > 0
        foundNp = stanfordNps[0]
        npModel.ref = foundNp
      elsif preSent.acceptableNps.length > 0
        foundNp = preSent.acceptableNps[0]
        preSent.npModels.push foundNp
        npModel.ref = foundNp
      end
    end
  end
  #end rules
  
  
  def printXml
    xml = "<TXT>"
    @sentences.each do |sentence|
      xml = "#{xml}\n#{sentence.xmlRep}\n"
    end
    xml = "#{xml}</TXT>"
    xml
  end
  
  #call this after we've set up the models
  def saveOutput
    tmpFile = "results/#{@fileName}.response"
    if File.exists?(tmpFile)
      File.delete(tmpFile)
    end
    
    file = File.open(tmpFile, "w")
    file.write printXml
    file.close
    
    lstFile = "listfile.txt"
    if File.exists? lstFile
      File.delete(lstFile)
    end
    
    file = File.open(lstFile, "w")
    file.write tmpFile
    file.close
  end

end