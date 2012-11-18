require 'java'
include Java
require '../stanford-ner-2012-07-09/stanford-ner.jar'
java_import 'edu.stanford.nlp.ie.crf.CRFClassifier'

# poro for handling info... i like strongly typed for this stuff
class NpModel
  #ref is a reference to another NpModel...
    #added grouping to be nicer looking in vi -ben
  attr_accessor :id, :startIdx, :endIdx, :sentIdx, :phrase, :sent,
		:ref, :included,
                
		:coref, :position, :pronounType, :article, :appositive, 
	   	:plurality, :properName, :semanticClass, :gender,
	    	:animacy, :headNoun
  
  #sent model, 
  def initialize(id, startIdx, endIdx, phrase, sent)
    @id = id
    @startIdx = startIdx
    @endIdx = endIdx
    @phrase = phrase
    @sent = sent #this is the sentence of the np right?
    identifyPlurality
    identifySemanticClass
  end

  def to_s 
    "#{phrase}"
  end
 
 #TODO change this to get the global head noun (since identifyHeadNoun should be called first) and identify if that is plural 
  def identifyPlurality
    words = @phrase.split(/\s+/)
    idx = words.length
    wordLength = words[idx-1].length
    if words[idx-1][wordLength-1] == 's'
      @plurality = true
    else
      @plurality = false
    end
  end

  #there are only 3 articles in english, 'a' 'an' and 'the'
  #so just look for those and we're golden
  def identifyArticle
    a_regex = /'a'/
    an_regex = /'an'/
    the_regex = /'the'/

    #i'm assuming the global phrase is the np as instantiated?
    
  end 
 
 #TODO identify the appositive
  def identifyAppositive


  end

 #TODO identify if it is a proper name or not (doing this simply by checking if it is two words
  #	and each start with a capitol letter at this point. can get more
  #	sophisticated later
  def identifyProperName

  end

  #going the stanford ner route as that seems simplest to import
  #returns true if identified, false if unknown
  def identifySemanticClass
    classifierRoute = "../stanford-ner-2012-07-09/classifiers/english.all.3class.distsim.crf.ser.gz"
    classifier = CRFClassifier.getClassifierNoExceptions(classifierRoute)
    #just going to do NER on the phrase for now, prob could change this to doing it on the whole sentence at some point and see if accuracy changes 
     classifiedPhrase = classifier.classifyToString(@phrase) 
     classHash = {}
     #build the hash
     classifiedPhrase.split(' ').each do |word|
	  k,v = word.split('/')
	  classHash[v] += 1
     end	 

     theoreticalNER = classHash.max_by { |k,v| v }
     unless theoreticalNER == 'O'
	 @semanticClass = theoreticalNER
     else
	 @semanticClass = 'UNKNOWN'
	 return false
     end
     
     true
  end

  #TODO identify the gender of the phrase (or should it be the head noun? could
  #	prob try both).
  def identifyGender

  end

  #TODO identify if the noun phrase is animate or not
  def identifyAnimacy

  end

  #TODO find the head noun
  def identifyHeadNoun
  end

end
