require 'java'
include Java
require '../stanford-ner-2012-07-09/stanford-ner.jar'
java_import 'edu.stanford.nlp.ie.crf'

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
    @sent = sent
    identifyPlurality
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

 #TODO identify the article in the noun phrase 
  def identifyArticle

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
  def identifySemanticClass

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
