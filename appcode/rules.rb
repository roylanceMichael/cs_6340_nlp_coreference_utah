class Rules

	#this will determine if the np's match in number
	def self.matchPlurality(npModel, idx, sentences)


	end

	def self.appositiveRule(npModel, sentences)
		#if this is true, then we want to set it to the previous npModel
		if npModel.appositive == true && npModel.sent != nil
			idx = 0

			npModel.sent.npModels.each do |npm|
				if npModel.id == npm.id
					break
				else
					idx = idx + 1
				end
			end

			if idx > 0
				ref = npModel.sent.npModels[idx-1]
				ref.included = true
				npModel.ref = ref
				true
			end
		end
		false
	end

	def self.wordsSubstring(npModel, sentIdx, sentences)
		prevSentences = []
	
		for i in 0...sentIdx
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

	#1 Incompatibility function: 1 if both are proper names, but mismatch on every word; else 0
	def self.properNames(npModel1, npModel2)
		if npModel1 != nil && npModel2 != nil
			if npModel1.properName && npModel2.properName
				compat = false

				np1Words = npModel1.phrase.split(/\s+/)
				np2Words = npModel2.phrase.split(/\s+/)
				
				np1Words.each do |word1|
					
					np2Words.each do |word2|
						if word1 == word2
							compat = true
						end

						if compat
							break
						end
					end

					if compat
						break
					end
				end

				if !compat
					return true
				end
			end
		end
		return false
	end

	#end new rules

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
		acceptableNps = []
		
		sentences[sentIdx-1].npModels.each do |model|
			acceptableNps.push model
		end

		sentences[sentIdx].npModels.select{|t| t.endIdx < npModel.startIdx}.each do |model|
			acceptableNps.push model
		end

	  if acceptableNps.length > 0
		lastAcceptableNp = acceptableNps[acceptableNps.length - 1]
		
		#acceptableNps.each do |nnp|
			#puts nnp
		#end

		#puts "found pronoun! #{npModel}"

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

  #aren't this and the words substring the same?
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
		foundNp.included = true
		npModel.ref = foundNp
	  elsif otherNps.length > 0
		foundNp = otherNps[0]
		foundNp.included = true
		npModel.ref = foundNp
	  end
	end
  end
end
