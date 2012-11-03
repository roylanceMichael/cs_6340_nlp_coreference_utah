require 'rexml/document'
require './parseAdapter.rb'
require './parseData.rb'
require './utilities.rb'
require './sentence.rb'
require './npModel.rb'

require './parseData.rb'
class Ncrf
  attr_accessor :xml, :fileName, :sentences, :nps, :seed, :parseAdapter
  
  #factory method for reading in a ton
  def self.factory(inputLoc)
	#inputLoc is a directory, read all files and process each one
	pa = ParseAdapter.new
	listFileContent = ""
	Dir.foreach(inputLoc) do |file|
		if (file =~ /(.+)\.crf/) != nil
			puts "processing #{$1}.crf..."
			content = (File.new "#{inputLoc}/#{$1}.crf").read
			ncrf = Ncrf.new content, $1, pa
			ncrf.produceXml
			listFileContent = "#{listFileContent}\nresults/#{$1}.response"
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
      if sentence.acceptableNps.length > 0 && sentence.npModels.length > 0
        
        np = sentence.acceptableNps[0]
        sentence.npModels.push np
        
        sentence.npModels.select{|t| t.coref}.each do |npModel|
          npModel.ref = np
        end
      end
    end
  end
  
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