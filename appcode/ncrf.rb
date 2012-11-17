require 'rexml/document'
require 'pathname'
require './parseAdapter.rb'
require './parseData.rb'
require './utilities.rb'
require './sentence.rb'
require './npModel.rb'
require './rules.rb'

class Ncrf
  attr_accessor :xml, :fileName, :sentences, :nps, :seed, :parseAdapter, :responseDir
  
  #factory method for reading in a ton
  def self.factory(inputLoc, responseDir)

	#inputLoc is a directory, read all files and process each one
	pa = ParseAdapter.new
	listFileLocations = (File.new inputLoc).read
	listFileContent = ""
	
	Dir.mkdir(responseDir) unless File.exists?(responseDir)
	arrayT = listFileLocations.split(/\s+/)
	
	listFileLocations.split(/\s+/).each do |file|
    
		  realFileName = Pathname.new(file).basename
		  realFileName.to_s =~ /(.+)\.crf/
			puts "processing #{file}..."
			content = (File.new file).read
			ncrf = Ncrf.new content, $1, pa, responseDir
			ncrf.produceXml
			
			#the scorer doesn't like empty results...
			if listFileContent == ""
		    listFileContent = "#{responseDir}/#{$1}.response"
		  else
		    listFileContent = "#{listFileContent}\n#{responseDir}/#{$1}.response"
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
  def initialize(xml, fileName, pa, responseDir)
    @responseDir = responseDir
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
  
  #defines the ids used for processing new corefs
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
      
      foundNps.sort_by{|word| word.length}.each do |foundNp|
        #puts "#{foundNp}"
        
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
          if(Rules.findItAnt(npModel, currentIdx, @sentences))
          elsif(Rules.findTheyAnt(npModel, currentIdx, @sentences))
          elsif(Rules.findSimilarName(npModel, currentIdx, @sentences))
          else
            Rules.findCorrectAnt(npModel, currentIdx, @sentences)
          end
        end
      end
      currentIdx = currentIdx + 1
    end
  end
  
  def printXml
    xml = "<TXT>"
    @sentences.each do |sentence|
      xml = "#{xml}\n#{sentence.xmlRep}"
    end
    xml = "#{xml}</TXT>"
    xml
  end
  
  #call this after we've set up the models
  def saveOutput
    tmpFile = "#{@responseDir}/#{@fileName}.response"
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