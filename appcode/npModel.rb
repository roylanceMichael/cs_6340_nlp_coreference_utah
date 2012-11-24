require 'java'
require 'rules.rb'
require 'utilities.rb'

include Java
require 'stanford-ner-2012-07-09/stanford-ner.jar'
java_import 'edu.stanford.nlp.ie.crf.CRFClassifier'

# poro for handling info... i like strongly typed for this stuff
class NpModel
  #ref is a reference to another NpModel...
  attr_accessor :id,:startIdx,:endIdx,:sentIdx,:phrase,:sent,
		:ref,:included,:coref,:position,:pronounType,
	       	:article,:appositive,:plurality,:properName,
	       	:semanticClass,:gender,:animacy
  
  classifierRoute = "stanford-ner-2012-07-09/classifiers/english.all.3class.distsim.crf.ser.gz"
  @@classifier = CRFClassifier.getClassifierNoExceptions(classifierRoute)

  #sent model, 
  #probably should pass in the parse tree from the orig np sent parse
  #to make certain identifications easier
  def initialize(id, startIdx, endIdx, phrase, sent)
    @id = id
    @startIdx = startIdx
    @endIdx = endIdx
    #TODO: maybe strip phrase of illegal characters here?
    @phrase = phrase
    @sent = sent #this is the sentence of the np right?
    identifyPlurality
    identifySemanticClass
    #can't identify it without the rest of the sentences...
    #identifyAppositive
    identifyGender
    identifyProperName
    identifyPronounType
    identifyAnimacy
    identifyArticle
  end

  def to_s 
    "#{@phrase} - id<#{@id}>pos<#{@position}>pron<#{@pronounType}>art<#{@article}>appos<#{@appositive}>plur<#{@plurality}>prop<#{@properName}>gend<#{@gender}>anim<#{@animacy}>"
  end

  #you do realize i did this in the identifyHeadNoun function
  #right?
  def headNoun
    words = @phrase.split(/\s+/)
    return words[words.length-1]
  end

  def identifyPronounType
    nominative = ["i", "he", "she", "we", "they"]
    accusative = ["me", "him", "her", "us", "them", "whom"]
    possessive = ["my", "your", "his", "our", "your", "their", "mine", "yours", "his", "hers", "ours", "yours", "theirs"]
    reflexive = ["myself", "yourself", "himself", "herself", "itself", "ourselves", "themselves"]
    ambiguous = ["you", "it"]

    normalizedPhrase = @phrase.downcase
    if nominative.include? normalizedPhrase
      @pronounType = "nomi"
    elsif accusative.include? normalizedPhrase
      @pronounType = "accu"
    elsif possessive.include? normalizedPhrase
      @pronounType = "poss"
    elsif ambiguous.include? normalizedPhrase
      @pronounType = "ambig"
    elsif reflexive.include? normalizedPhrase
    else
      @pronounType = "none"
    end
  end
 
  def identifyPlurality
    #if the phrase includes a plural pronoun, it's plural 
    pluralPronoun = ["we","they","us","them","our","ours"]
    normalizedPhrase = @phrase.downcase
    if pluralPronoun.include? normalizedPhrase
	   @plurality = true
	   return
    end

    #if the phrases head noun ends in an 's', it's plural 
    words = @phrase.split(/\s+/)
    idx = words.length
    wordLength = words[idx-1].length
    if words[idx-1][wordLength-1] == 's'
      @plurality = true
    else
      @plurality = false
    end
  end

  #prob will need to be refactored later
  #returns true if matched an article, false if no article
  def identifyArticle
    a_regex = /\s+a\s+/
    an_regex = /\s+an\s+/
    the_regex = /\s+the\s+/
    some_regex = /\s+some\s+/

    if(a_regex.match(@phrase))
	@article = "a" 
	return true	
    elsif(an_regex.match(@phrase))
	@article = "an" 
	return true	
    elsif(the_regex.match(@phrase))
	@article = "the" 
	return true	
    elsif(some_regex.match(@phrase))
	@article = "some"
	return true
    else
	@article = "NONE"
    end

    false
  end 

  #using appositive definition from clustering algorithm 
  def identifyAppositive
    #if np is surrounded by commas
    #not sure if this will get appositives as defined by the paper,
    #but we can try it out
    if @startIdx > 0
      prevWord = @sent.sent[@startIdx-1]
      
      #only going to get the ones with a single comma...
      if prevWord == ","
        #is the prev word part of an NP?
        nextNp = @sent.npModels.select{|t| t.endIdx == @startIdx - 2}

        if nextNp.length == 1 && false
          #puts "<#{prevWord}> <#{sent.strRep}> <#{nextNp[0].phrase} #{nextNp[0].id}> <- <#{self.phrase} #{self.id}>"
          self.ref = nextNp[0]
          nextNp[0].included = true
          @appositive = true
        end
      end
      @appositive = false
    #let's just try this for now, will test later
    elsif phrase.chars.to_a[0] == ","
      @appositive = true
    else
      @appositive = false
    end
  end

  #checks if all words have capitol starting
  #and/or semantic class == 'PERSON'
  def identifyProperName
    words = @phrase.split(' ')

    #this maybe should change to not check semanticClass
    #depends on how the NER system is going to be accurate or not
    #...we'll see
    unless @semanticClass != "PERSON"
	tempStatus = true 
    else
	tempStatus = false
    end

    capRegex = /^[A-Z]/
    
    words.each do |word|
	if(capRegex.match(word) != nil)
	    tempStatus = true
	else
	    @properName = false
	end	    
    end

    @properName = tempStatus unless @properName == false
    
    tempStatus
  end

  #going the stanford ner route as that seems simplest to import
  #returns true if identified, false if unknown
  def identifySemanticClass
    #just going to do NER on the phrase for now, prob could change this to doing it on the whole sentence at some point and see if accuracy changes 
     classifiedPhrase = @@classifier.classifyToString(@phrase) 
     classHash = {}
     #build the hash
     classifiedPhrase.split(' ').each do |word|
	  k,v = word.split('/')
	  unless classHash[v] == nil
	      classHash[v] += 1
	  else
	      classHash[v] = 1
	  end
     end	 

     theoreticalNER = classHash.max_by { |k,v| v }
     unless theoreticalNER[0] == 'O'
	 @semanticClass = theoreticalNER[0]
     else
	 @semanticClass = 'UNKNOWN'
	 return false
     end
     
     true
  end

  #if it contains 'he', 'his' => male
  #if it contains 'she', 'her' => female
  #if it contains 'it' => unknown
  #TODO: test
  #TODO: add in common female names
  def identifyGender
   male = [/\b[Hh]e\b/, /\b[Hh]is\b/, /\b[Hh]imself\b/, 
	   /\b[Hh]im\b/]

   #get male names from file 
   #this'll probably result in a slowdown...probably should
   #make this static accross all classes
   male_names = []
   File.readlines("male_names.txt").each do |line|
	male_names << line	
   end

   female = [/\b[Ss]he\b/,/\b[Hh]er\b/, /\b[Hh]erself\b/,
	     /\b[Hh]ers\b/]
   it = /\b[Ii]t\b/
    
    #if it's a male name, consider the gender to be
    #male no matter what 
    @phrase.split(' ').each do |word|
	if(male_names.include?(word.upcase))
	    gender = "MALE"
	    return	    
	end
    end
	
    male.each do |regex|
       if(regex.match(@phrase) != nil)
	   gender = "MALE" 
       end
    end

    female.each do |regex|
       if(regex.match(@phrase) != nil) 
	   gender = "FEMALE" 
       end
    end

     if(it.match(@phrase) != nil)
	 gender = "UNKNOWN"
     end
  end

  #TODO identify if the noun phrase is animate or not
  #	right now doing a simple semantic class check, its the
  #	only thing i can think of to do an animacy check atm. we
  #	can change it later if it doesnt work out. this might
  #	require some machine learning to get to work with any
  #	sort of real accuracy...unless i can find a tool today
  #	to do it for us (here's hoping..)
  def identifyAnimacy
	if(@semanticClass != "PERSON")
	    @animacy = 'inanimate'
	else
	    @animacy = 'animate' 
	end   
  end

  #for the purposes of the clustering algorithm,
  #the last word in the np is considered the head noun
  def identifyHeadNoun
     words = @phrase.split(' ')
     @headNoun = words[words.length-1]

     true
  end

  def findBestMatch(currentIdx, allSentences)
    #candidates are all the words that come before current 
    if @ref != nil
      return
    end

    #let's get -infinity rules first - can't get appositive to work right now, will tweak later...
    if (Rules.appositiveRule(self, currentIdx, allSentences)) && false
      #puts "appositive rules applied"
    elsif (Rules.wordsSubstring(self, currentIdx, allSentences))
      #puts "wordssubstring rule applied"
    else
      #puts "random fun... will be using better heuristics for this..."
      Rules.findCorrectAnt(self, currentIdx, allSentences)
    end

  end
end
