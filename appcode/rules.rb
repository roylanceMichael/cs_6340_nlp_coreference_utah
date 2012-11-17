class Rules
	#it usually belongs to the sentence right before it. 
  def self.findItAnt(npModel, sentIdx, sentences)
	if(npModel.phrase.downcase.lstrip.rstrip == "it" && sentIdx > 0)
	  prevSent = sentences[sentIdx]
	  
	  #get the first np
	  firstNp = prevSent.npModels.sort{|a, b| a.startIdx <=> b.startIdx}

	  #prevSent.npModels.each do |model|
	  	#puts model
	  #end
	  
	  if firstNp.length > 0
		firstNp[0].included = true
		npModel.ref = firstNp[0]
		
		#puts "findItAnt - #{npModel} - #{firstNp[0]}"

		return true
	  end
	end
	false
  end

  def self.findTheyAnt(npModel, sentIdx, sentences)
	pronoun = npModel.phrase.downcase.lstrip.rstrip
	pronouns = ["i", "me", "my", "mine", "myself", "you", "your", "yours", 
	  "yourself", "we", "us", "our", "ours", "ourselves", "yourselves", "she",
	  "he", "him", "his", "himself", "hers", "her", "herself", "they", "them",
	  "their", "theirs", "themselves"]
	
	if (pronouns.include?(pronoun))
	  sent = sentences[sentIdx]
	  
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


  def self.findSimilarName(npModel, sentIdx, sentences)
	prevSentences = []
	
	for i in 0..sentIdx
	  prevSentences.push sentences[i]
	end
	
	#starting at the beginning, find the first np with any sort of match to our current phrase
	npPhrase = npModel.phrase.split(/\s+/)
	regexs = []
	npPhrase.each do |word|
	  regexs.push word
	end
	
	match = false
	
	prevSentences.each do |prevSent|
	  
	  prevSent.npModels.each do |acceptableNp|
		
		regexs.each do |regex|
		  
		  acceptableNp.phrase.split(/\s+/).each do |word|
			
			if Utilities.editDistance(regex, word) <= 2
			  #this acceptableNp is a match
			  acceptableNp.included = true
			  npModel.ref = acceptableNp

			  return true
			end
		  end
		end
	  end
	end
	
	false
  end

 def self.findCorrectAnt(npModel, sentIdx, sentences)
	#right now, just going to find the first np in the preceding sentence
	if sentIdx > 0
	  preSentIdx = sentIdx - 1
	  preSent = sentences[preSentIdx]
	  
	  #do I exist in my npModels right now?
	  stanfordNps = preSent.npModels.select{|t| t.coref == false }
	  otherNps = preSent.npModels.select{|t| t.coref == true}
	  if stanfordNps.length > 0
		foundNp = stanfordNps[0]
		npModel.ref = foundNp
	  elsif otherNps.length > 0
		foundNp = otherNps[0]
		npModel.ref = foundNp
	  end
	end
  end
end